import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goalytics_mobile/dream_squad/services/dream_squad_service.dart';
import 'package:goalytics_mobile/dream_squad/models/dream_squad_models.dart';
import '../../../main/services/api_config.dart';
import 'dart:convert';

class AppColors {
  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate500 = Color(0xFF64748B);
  static const slate700 = Color(0xFF334155);
  static const slate900 = Color(0xFF0F172A);
  static const emerald600 = Color(0xFF059669);
  static const rose50 = Color(0xFFFFF1F2);
  static const rose500 = Color(0xFFF43F5E);
  static const amber500 = Color(0xFFF59E0B);
  static const sky500 = Color(0xFF0EA5E9);
  static const indigo50 = Color(0xFFEEF2FF);
  static const indigo = Colors.indigo;
}

class SquadFormPage extends StatefulWidget {
  final int? squadId;
  final String? initialName;

  const SquadFormPage({super.key, this.squadId, this.initialName});

  @override
  State<SquadFormPage> createState() => _SquadFormPageState();
}

class _SquadFormPageState extends State<SquadFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  late DreamSquadService _service;
  bool _isLoading = false;

  List<DiscoveryPlayer> _searchResults = [];
  List<Map<String, dynamic>> _selectedPlayers = [];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _service = DreamSquadService(context.read<CookieRequest>(), baseUrl: ApiConfig.baseUrl);

    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    if (widget.squadId != null) {
      _loadInitialData();
    }
    // load initial discovery players (empty query loads default set)
    _loadInitialDiscovery();

    // wire up debounce on typing
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim();
    // debounce: wait 400ms after user stops typing
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _handleSearch(q);
    });
  }

  Future<void> _loadInitialDiscovery() async {
    setState(() => _isLoading = true);
    try {
      // call search with empty query to get default discovery (first page)
      final results = await _service.searchPlayers('');
      if (!mounted) return;
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      debugPrint("Failed to load initial discovery: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load players: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Ambil data mentah (Map) dari service
      final data = await _service.getSquadDetail(widget.squadId!);

      // 2. Akses list pemain menggunakan key 'current_players'
      final List<dynamic> players = data['current_players'] ?? [];

      setState(() {
        // 3. Mapping data dari Map ke list lokal Anda
        _SelectedPlayersSetFrom(players);

        _isLoading = false;
      });

      // optionally refresh searchResults so selected players show as selected
      setState(() {});
    } catch (e) {
      debugPrint("Error loading squad detail for edit: $e");
      setState(() => _isLoading = false);
    }
  }

  void _SelectedPlayersSetFrom(List<dynamic> players) {
    _selectedPlayers = players.map((p) => {
      'id': p['id'],
      'name': p['name'],
      'position': p['position'],
    }).toList();
  }

  Future<void> _handleSearch(String query) async {
    final q = (query ?? '').trim();
    if (q.isEmpty) {
      // jika query kosong, kita load default discovery (atau kosongkan)
      await _loadInitialDiscovery();
      return;
    }

    setState(() {
      _isLoading = true;
      // keep previous results visible while loading or clear — choose to keep previous
    });

    try {
      final results = await _service.searchPlayers(q);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint("search error: $e\n$st");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Search failed: $e")));
    }
  }

  void _togglePlayer(dynamic player) {
    setState(() {
      // player is DiscoveryPlayer instance
      final index = _selectedPlayers.indexWhere((p) => p['id'] == player.id);
      if (index >= 0) {
        _selectedPlayers.removeAt(index);
      } else {
        // prevent adding duplicates just in case
        if (!_selectedPlayers.any((p) => p['id'] == player.id)) {
          _selectedPlayers.add({
            'id': player.id,
            'name': player.name,
            'position': player.position,
          });
        }
      }
    });
  }

  // NEW: reliable helper to remove selected player by id (no fake DiscoveryPlayer)
  void _removeSelectedById(int id) {
    setState(() {
      _selectedPlayers.removeWhere((sp) => sp['id'] == id);
      debugPrint('Removed player id=$id, remaining=${_selectedPlayers.length}');
    });
  }

  Future<void> _saveSquad() async {
    if (!_formKey.currentState!.validate()) return;

    final List<int> playerIds = _selectedPlayers.map((p) => p['id'] as int).toList();

    setState(() => _isLoading = true);
    try {
      final response = await _service.saveSquad(
        id: widget.squadId,
        name: _nameController.text,
        playerIds: playerIds,
      );

      if (mounted) {
        if (response['success'] == true) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Squad saved successfully!")),
          );
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${response['error'] ?? 'Unknown error'}")),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  bool _isSelectedById(int id) {
    return _selectedPlayers.any((p) => p['id'] == id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(widget.squadId == null ? "Build New Squad" : "Edit Squad",
            style: TextStyle(color: AppColors.slate900)),
        iconTheme: IconThemeData(color: AppColors.slate900),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSquad,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.slate900,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12)
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // wide layout (desktop/tablet) -> two columns
          final isWide = constraints.maxWidth > 900;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column (form + roster) fixed width
                Container(
                  width: 360,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildFormCard(),
                      const SizedBox(height: 20),
                      // make roster flexible inside left column
                      Expanded(child: _buildRosterCard()),
                    ],
                  ),
                ),

                // Separator
                const SizedBox(width: 20),

                // Right column (discovery) expanded
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 40, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDiscoveryHeader(),
                        const SizedBox(height: 12),
                        Expanded(child: _buildDiscoveryGrid()),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // mobile / narrow layout: single column (improved responsiveness)
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormCard(),
                  const SizedBox(height: 16),
                  // Roster card - not Expanded on mobile; fixed height so interactions work
                  SizedBox(height: 260, child: _buildRosterCard()),
                  const SizedBox(height: 16),
                  const Text("Discover Players", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by name...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => _handleSearch(_searchController.text),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: _handleSearch,
                  ),
                  const SizedBox(height: 12),
                  _buildSearchResultsList(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Edit Squad", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("Squad Name", style: TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Enter squad name...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
                validator: (value) => value!.isEmpty ? "Name is required" : null,
              ),
            ),
            const SizedBox(height: 18),
            // Save & Cancel row (Save is in appbar but keep a big button here too to match style)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveSquad,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.slate900,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text("Cancel"),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Roster card now returns a normal Widget so it can be used both inside Expanded (desktop)
  // and inside SizedBox (mobile). This avoids Expanded-in-unbounded-height issues on mobile.
  Widget _buildRosterCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header with badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Current Player", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("${_selectedPlayers.length} Players", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 12),
            // flexible list area
            Expanded(
              child: _selectedPlayers.isEmpty
                  ? const Center(child: Text("No players added yet.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)))
                  : ListView.separated(
                itemCount: _selectedPlayers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final p = _selectedPlayers[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slate100),
                    ),
                    child: ListTile(
                      title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(p['position'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      // REPLACED: use IconButton + helper that removes by id (no fake DiscoveryPlayer)
                      trailing: IconButton(
                        onPressed: () {
                          final idVal = p['id'];
                          // ensure id is int
                          final idInt = idVal is int ? idVal : int.tryParse(idVal.toString());
                          if (idInt != null) {
                            _removeSelectedById(idInt);
                          } else {
                            debugPrint('Invalid id for removal: $idVal');
                          }
                        },
                        icon: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.rose50,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.close, color: AppColors.rose500, size: 18),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Discover Players", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Search and add players to your squad roster.", style: TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
        SizedBox(
          width: 360,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search by name...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _handleSearch(_searchController.text),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onSubmitted: _handleSearch,
          ),
        )
      ],
    );
  }

  Widget _buildDiscoveryGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(child: Text("No players found. Try searching."));
    }

    // Responsive columns based on current width
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount;
    if (width > 1200) {
      crossAxisCount = 4;
    } else if (width > 900) {
      crossAxisCount = 3;
    } else if (width > 600) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 6),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: (crossAxisCount == 1) ? 4.5 : 3.6,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final p = _searchResults[index];
        final isSelected = _isSelectedById(p.id);

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              // make tapping the card toggle selection as well (improves mobile UX)
              _togglePlayer(p);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.slate100),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // optional avatar placeholder (initials)
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.indigo50,
                    child: Text(
                      (p.name.isNotEmpty ? p.name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join() : '?'),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("${p.position} | ${p.clubName}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Add / Remove pill button
                  InkWell(
                    onTap: () {
                      _togglePlayer(p);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.rose50 : AppColors.indigo50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        isSelected ? "Remove" : "Add",
                        style: TextStyle(
                          color: isSelected ? AppColors.rose500 : AppColors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // fallback mobile list (kept for narrow screens)
  Widget _buildSearchResultsList() {
    if (_isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: CircularProgressIndicator(),
      ));
    }

    if (_searchResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: Text("Search players to add to your squad")),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final p = _searchResults[index];
        final isSelected = _isSelectedById(p.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${p.position} • ${p.clubName}"),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? AppColors.rose50 : AppColors.indigo50,
                foregroundColor: isSelected ? AppColors.rose500 : AppColors.indigo,
                elevation: 0,
              ),
              onPressed: () => _togglePlayer(p),
              child: Text(isSelected ? "Remove" : "Add"),
            ),
          ),
        );
      },
    );
  }
}
