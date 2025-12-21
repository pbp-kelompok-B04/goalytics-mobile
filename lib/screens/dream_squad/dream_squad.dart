// lib/screens/dream_squad/dream_squad.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goalytics_mobile/service/dream_squad_service.dart';
import 'package:goalytics_mobile/models/dream_squad_models.dart';
import 'package:goalytics_mobile/widgets/bottom_nav.dart';
import 'package:goalytics_mobile/service/api_config.dart';
import 'package:goalytics_mobile/screens/dream_squad/squad_detail.dart';
import 'package:goalytics_mobile/screens/dream_squad/edit_squad.dart';
import 'player_detail.dart';
import 'dart:async';

// ==========================================
// PALETTE WARNA
// ==========================================
class AppColors {
  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate500 = Color(0xFF64748B);
  static const slate700 = Color(0xFF334155);
  static const slate900 = Color(0xFF0F172A);
  static const emerald600 = Color(0xFF059669);
  static const rose500 = Color(0xFFF43F5E);
  static const amber500 = Color(0xFFF59E0B);
  static const sky500 = Color(0xFF0EA5E9);
  static const indigo = Colors.indigo;
  static const indigo50 = Color(0xFFEEF2FF);
}

class DreamSquadPage extends StatefulWidget {
  const DreamSquadPage({super.key});

  @override
  State<DreamSquadPage> createState() => _DreamSquadPageState();
}

class _DreamSquadPageState extends State<DreamSquadPage> {
  // State Variables
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _bannedWordController = TextEditingController();
  List<int> favoriteIds = []; // <- perbaikan: id adalah int
  Timer? _debounce;
  List<DiscoveryPlayer> _discoveryResults = [];
  late Future<SquadModel> _initialFuture;
  bool _isSearching = false;

  late DreamSquadService _service;
  CookieRequest? _request;

  bool _isLoading = false;
  bool _isInitialLoading = true;

  List<MySquad> _squads = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _request = Provider.of<CookieRequest>(context, listen: false);
    _service = DreamSquadService(_request!, baseUrl: ApiConfig.baseUrl);

    if (_isInitialLoading) {
      _isInitialLoading = false;
      _loadSquads();
      _initialFuture = _service.fetchSquadList();
    }
  }


  @override
  void dispose() {
    _searchController.dispose();
    _bannedWordController.dispose();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    super.dispose();
  }

  Future<void> _loadSquads() async {
    try {
      final squadData = await _service.fetchSquadList();
      if (!mounted) return;
      setState(() {
        _squads = squadData.mySquads;
      });
    } catch (e, st) {
      debugPrint("Failed to load squads for modal: $e\n$st");
      // tampilkan pesan yang lebih informatif ke user bila perlu
      if (mounted) {
        _showSnackBar("Failed to load squads: ${e.toString()}", AppColors.rose500);
      }
    }
  }

  /// Refresh both local _squads and the Future used by FutureBuilder
  Future<void> _refreshSquads() async {
    try {
      await _loadSquads(); // update _squads
      // refresh the future used by FutureBuilder so snapshot data juga ter-update
      _initialFuture = _service.fetchSquadList();
      if (mounted) setState(() {}); // trigger rebuild
    } catch (e) {
      debugPrint("Failed to refresh squads: $e");
    }
  }


  // Debounced search that populates _discoveryResults
  void _refreshData() {
    final queryNow = _searchController.text.trim();

    if (queryNow.isEmpty) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      if (mounted) {
        setState(() {
          _discoveryResults = [];
          _isSearching = false; // reset
        });
      }
      return;
    }

    // show local searching spinner
    if (mounted) setState(() => _isSearching = true);

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      final capturedQuery = _searchController.text.trim();
      if (capturedQuery.isEmpty) {
        if (mounted) setState(() {
          _discoveryResults = [];
          _isSearching = false;
        });
        return;
      }

      try {
        final results = await _service.searchPlayers(capturedQuery);

        if (!mounted) return;
        if (capturedQuery != _searchController.text.trim()) {
          // response usang -> abaikan
          return;
        }

        setState(() {
          _discoveryResults = results;
          _isSearching = false;
        });
      } catch (e) {
        debugPrint("Search error: $e");
        if (!mounted) return;
        setState(() {
          _discoveryResults = [];
          _isSearching = false;
        });
      }
    });
  }


  // ================= LOGIC ACTIONS =================

  Future<void> _addBannedWord() async {
    final word = _bannedWordController.text.trim();
    if (word.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await _service.addBannedWord(word);

      if (response['success'] == true) {
        _showSnackBar(response['message'] ?? "Word banned", AppColors.emerald600);
        _bannedWordController.clear();
      } else {
        _showSnackBar(response['error'] ?? "Failed to add word", AppColors.rose500);
      }
    } catch (e) {
      _showSnackBar("Error: $e", AppColors.rose500);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Squad", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this squad forever?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: AppColors.slate500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: AppColors.rose500, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirm) return;

    setState(() => _isLoading = true);

    try {
      final response = await _service.deleteSquad(id);

      if (response?['success'] == true) {
        _showSnackBar(response['message'], AppColors.emerald600);
        // reload squads
        await _loadSquads();
        if (mounted) setState(() => _isLoading = false);
      } else {
        _showSnackBar(response?['error'] ?? "Failed to delete squad", AppColors.rose500);
      }
    } catch (e) {
      _showSnackBar("Connection error: $e", AppColors.rose500);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= UI BUILDER =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Dream Squads',
          style: TextStyle(color: AppColors.slate900, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.slate900),
      ),
      body: Stack(
        children: [
          FutureBuilder<SquadModel>(
            future: _initialFuture,  // <- fixed: tanpa query argumen
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.rose500),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: () {
                              _initialFuture = _service.fetchSquadList();
                              setState(() {});
                            },
                          child: const Text("Retry"),
                        )
                      ],
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.success) {
                return const Center(child: Text('No data available or session expired.'));
              }

              final squadModel = snapshot.data!;
              final isAdmin = squadModel.isAdmin;

              return RefreshIndicator(
                onRefresh: () async {
                  // refresh page by forcing rebuild + reload squads
                  await _loadSquads();
                  setState(() {});
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildStatsSection(squadModel.stats),
                      const SizedBox(height: 24),
                      if (isAdmin) ...[
                        _buildPopularPlayers(squadModel.adminExtras.popularPlayers),
                        const SizedBox(height: 24),
                        _buildBannedWordsSection(squadModel.adminExtras.bannedWords),
                        const SizedBox(height: 24),
                      ],
                      _buildSavedSquadsSection(_squads),
                      const SizedBox(height: 24),
                      // pass server-provided discoveryPlayers as fallback
                      _buildDiscoverPlayersSection(squadModel.discoveryPlayers),
                    ],
                  ),
                ),
              );
            },
          ),

          if (_isLoading)
            Container(
              color: AppColors.slate900.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),bottomNavigationBar: const BottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "DREAM SQUAD",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate500,
                    letterSpacing: 1.2),
              ),
              Text(
                "Manage Squads",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate900),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: _showCreateSquadModal,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.slate900,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Create Squad'),
        ),
      ],
    );
  }

  Widget _buildStatsSection(GlobalStats stats) {
    return Row(
      children: [
        _statCard("Squads", stats.totalSquads.toString(), AppColors.rose500),
        const SizedBox(width: 12),
        _statCard("Players", stats.totalPlayersUsed.toString(), AppColors.amber500),
        const SizedBox(width: 12),
        _statCard("Avg Age", stats.averageAge.toStringAsFixed(1), AppColors.sky500),
      ],
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.slate500)),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularPlayers(List<DiscoveryPlayer> players) {
    if (players.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Most Popular Players (Global)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.slate900),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: players.length,
            itemBuilder: (context, index) {
              final p = players[index];
              final String initials = p.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase();

              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.slate100,
                      backgroundImage: p.imageUrl != null && p.imageUrl!.isNotEmpty ? NetworkImage(p.imageUrl!) : null,
                      child: p.imageUrl == null || p.imageUrl!.isEmpty
                          ? Text(initials, style: const TextStyle(color: AppColors.slate500, fontWeight: FontWeight.bold))
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      p.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${p.usage ?? 0} Squads",
                      style: const TextStyle(fontSize: 11, color: AppColors.slate700, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBannedWordsSection(List<dynamic> words) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _bannedWordController,
                  decoration: const InputDecoration(
                    hintText: "Ban a word...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(onPressed: _addBannedWord, icon: const Icon(Icons.block, color: AppColors.rose500))
            ],
          ),
          if (words.isNotEmpty) const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: words
                .map((w) => Chip(
              label: Text(
                w.toString(),
                style: const TextStyle(fontSize: 12, color: AppColors.slate700),
              ),
              backgroundColor: AppColors.slate100,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ))
                .toList(),
          )
        ],
      ),
    );
  }

  Widget _buildSavedSquadsSection(List<MySquad> squads) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Saved Squads",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Your previously created dream squads.",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        if (squads.isEmpty)
          const Text("No squads yet.")
        else
          ...squads.map((squad) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        squad.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${squad.playerCount} players",
                        style: TextStyle(color: Colors.blueGrey.shade400),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildActionButton(
                      label: "Open",
                      color: const Color(0xFF0F172A),
                      textColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SquadDetailPage(squadId: squad.id),
                          ),
                        ).then((_) async {
                          // ketika kembali dari SquadDetailPage, refresh list
                          await _loadSquads();
                        });
                      },
                    ),
                    _buildActionButton(
                      label: "Edit",
                      color: Colors.white,
                      textColor: Colors.black,
                      borderColor: Colors.grey.shade200,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SquadFormPage(squadId: squad.id, initialName: squad.name),
                          ),
                        ).then((_) async => await _refreshSquads());
                      },
                    ),
                    _buildActionButton(
                      label: "Delete",
                      color: const Color(0xFFFFF1F2),
                      textColor: Colors.red,
                      onTap: () => _handleDelete(squad.id),
                    ),
                  ],
                ),
              ],
            ),
          )),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverPlayersSection(List<DiscoveryPlayer> discoveryPlayers) {
    // Jika user mengetik, pakai hasil pencarian debounced; kalau tidak, pakai discoveryPlayers dari server
    final bool usingSearch = _searchController.text.trim().isNotEmpty;
    final List<DiscoveryPlayer> listToShow = usingSearch ? _discoveryResults : discoveryPlayers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Discover Players",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.slate900),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          onChanged: (_) => _refreshData(),
          decoration: const InputDecoration(
            hintText: "Search players or teams...",
            prefixIcon: Icon(Icons.search, color: AppColors.slate500),
          ),
        ),
        const SizedBox(height: 20),
        if (_isSearching)
          const Center(child: CircularProgressIndicator())
        else if (listToShow.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text("No players found."),
          ))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listToShow.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 5 : (MediaQuery.of(context).size.width > 800 ? 3 : 2),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 200,
            ),
            itemBuilder: (context, index) {
              return _buildPlayerCard(listToShow[index]);
            },
          ),
      ],
    );
  }

  Widget _buildPlayerCard(DiscoveryPlayer player) {
    bool isAdded = favoriteIds.contains(player.id);
    final String initials = player.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerDetailPage(playerId: player.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.slate200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.slate100,
              backgroundImage: (player.imageUrl != null && player.imageUrl!.isNotEmpty) ? NetworkImage(player.imageUrl!) : null,
              child: (player.imageUrl == null || player.imageUrl!.isEmpty)
                  ? Text(initials, style: const TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              player.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate900),
            ),
            Text(
              player.clubName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.slate500),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statMiniItem(Icons.trending_up, player.goals.toString(), AppColors.emerald600),
                const SizedBox(width: 9),
                _statMiniItem(Icons.check_circle_outline, player.assists.toString(), AppColors.sky500),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 30,
              child: isAdded ? _buildAddedButton() : _buildAddButton(player.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statMiniItem(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 2),
        Text(value, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.slate700)),
      ],
    );
  }

  Widget _buildAddButton(int playerId) {
    return ElevatedButton(
      onPressed: () => openSelectSquadModal(playerId),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.slate50,
        foregroundColor: AppColors.slate500,
        elevation: 0,
      ),
      child: const Text("Add", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAddedButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.emerald600.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.emerald600.withOpacity(0.5)),
      ),
      child: const Center(
        child: Icon(Icons.check, size: 14, color: AppColors.emerald600),
      ),
    );
  }

  Widget _smallStat(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          "$value",
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.slate700),
        ),
      ],
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCreateSquadModal() {
    final nameController = TextEditingController();
    int? selectedGkId, selectedDfId, selectedMfId, selectedFwId;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 500),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _service.fetchPlayersForModal(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator(color: AppColors.slate900)),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data?['success'] == false) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Error: Failed to load grouped players."),
                    );
                  }

                  final playersByPos = snapshot.data?['players_by_pos'];
                  List<dynamic> getList(String key) => playersByPos[key] ?? [];

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Create New Squad",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.slate900)),
                            if (!isSubmitting)
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close, color: AppColors.slate500),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text("Squad Name", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.slate700)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            hintText: "My Awesome Team",
                            filled: true,
                            fillColor: AppColors.slate50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 24),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 2.1,
                          children: [
                            _buildDropdownItem("GK", getList('GK'), selectedGkId, isSubmitting ? null : (val) => setModalState(() => selectedGkId = val)),
                            _buildDropdownItem("DF", getList('DF'), selectedDfId, isSubmitting ? null : (val) => setModalState(() => selectedDfId = val)),
                            _buildDropdownItem("MF", getList('MF'), selectedMfId, isSubmitting ? null : (val) => setModalState(() => selectedMfId = val)),
                            _buildDropdownItem("FW", getList('FW'), selectedFwId, isSubmitting ? null : (val) => setModalState(() => selectedFwId = val)),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!isSubmitting)
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel", style: TextStyle(color: AppColors.slate500, fontWeight: FontWeight.bold)),
                              ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.slate900,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                  final name = nameController.text.trim();
                                  if (name.isEmpty || selectedGkId == null || selectedDfId == null || selectedMfId == null || selectedFwId == null) {
                                    _showSnackBar("Please fill all fields", AppColors.rose500);
                                    return;
                                  }

                                  setModalState(() => isSubmitting = true);

                                  try {
                                    final selectedIds = [selectedGkId!, selectedDfId!, selectedMfId!, selectedFwId!];
                                    final response = await _service.createSquad(name, selectedIds);

                                    if (response?['success'] == true) {
                                      if (mounted) Navigator.pop(context);
                                      _showSnackBar(response!['message'], AppColors.emerald600);
                                      await _loadSquads();
                                    } else {
                                      setModalState(() => isSubmitting = false);
                                      _showSnackBar(response?['error'] ?? "Failed", AppColors.rose500);
                                    }
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    _showSnackBar("Error: $e", AppColors.rose500);
                                  }
                                },
                                child: isSubmitting
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text("Create Squad", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildDropdownItem(String label, List<dynamic> players, int? selectedValue, void Function(int?)? onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.slate500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              menuMaxHeight: 300,
              value: selectedValue,
              hint: Text("Select $label", style: const TextStyle(fontSize: 11, color: AppColors.slate500)),
              items: players.map((p) => DropdownMenuItem<int>(
                value: p['id'],
                child: Text(p['name'], style: const TextStyle(fontSize: 12, color: AppColors.slate900), overflow: TextOverflow.ellipsis),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  /// Modal untuk memilih squad tujuan ketika user menekan Add pada player card
  Future<void> openSelectSquadModal(int playerId) async {
    // Pastikan squads sudah termuat
    if (_squads.isEmpty) {
      await _loadSquads();
    }
    if (!mounted) return;

    // Kapasitas maksimal squad (override lokal)
    const int maxCap = 22;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        int? chosenSquadId;
        bool isSubmitting = false;

        return StatefulBuilder(builder: (context, setModalState) {
          MySquad? _findSquadById(int? id) =>
              id == null ? null : _squads.firstWhere((s) => s.id == id, orElse: () => MySquad(id: -1, name: 'Unknown', playerCount: 0));

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520, maxHeight: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      border: Border(bottom: BorderSide(color: AppColors.slate200)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Add player to squad",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.slate900)),
                              SizedBox(height: 6),
                              Text("Choose the squad where this player will be added.",
                                  style: TextStyle(fontSize: 12, color: AppColors.slate500)),
                            ],
                          ),
                        ),
                        if (isSubmitting)
                          const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.slate500),
                            onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
                          ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: _squads.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.inbox, size: 48, color: AppColors.slate200),
                            SizedBox(height: 12),
                            Text("You don't have any squads yet.\nCreate one first to add players.",
                                textAlign: TextAlign.center, style: TextStyle(color: AppColors.slate500)),
                          ],
                        ),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Material(
                          color: Colors.white,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _squads.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final s = _squads[index];
                              final bool isFull = s.playerCount >= maxCap;
                              final bool selected = chosenSquadId == s.id;
                              final double fill = (s.playerCount / maxCap).clamp(0.0, 1.0);

                              return InkWell(
                                onTap: (isFull || isSubmitting)
                                    ? null
                                    : () => setModalState(() => chosenSquadId = s.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  color: selected ? AppColors.indigo50.withOpacity(0.35) : Colors.white,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.slate100,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            s.name.isNotEmpty ? s.name[0].toUpperCase() : "?",
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate700),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    s.name,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.slate900,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: isFull ? Colors.red.shade50 : AppColors.slate100,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: isFull ? Colors.red.shade100 : AppColors.slate200),
                                                  ),
                                                  child: Text(
                                                    "${s.playerCount}/$maxCap${isFull ? ' • Full' : ''}",
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color: isFull ? Colors.red.shade700 : AppColors.slate700),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 6,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(6),
                                                child: LinearProgressIndicator(
                                                  value: fill,
                                                  minHeight: 6,
                                                  backgroundColor: AppColors.slate100,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text("${s.playerCount} players", style: const TextStyle(fontSize: 11, color: AppColors.slate500)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      if (isFull)
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.block, color: Colors.redAccent, size: 18),
                                            SizedBox(height: 4),
                                            Text('Full', style: TextStyle(fontSize: 10, color: Colors.redAccent)),
                                          ],
                                        )
                                      else
                                        Radio<int>(
                                          value: s.id,
                                          groupValue: chosenSquadId,
                                          onChanged: (isSubmitting) ? null : (val) => setModalState(() => chosenSquadId = val),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Actions
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      border: Border(top: BorderSide(color: AppColors.slate200)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
                            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: (chosenSquadId == null || isSubmitting)
                                ? null
                                : () async {
                              // double-check selected squad capacity before sending
                              final selected = _findSquadById(chosenSquadId);
                              if (selected == null || selected.id == -1) {
                                // unexpected — reset selection
                                setModalState(() => chosenSquadId = null);
                                return;
                              }
                              if (selected.playerCount >= maxCap) {
                                // sudah penuh (mungkin race condition) — beri tahu user dan jangan submit
                                setModalState(() => chosenSquadId = null);
                                _showSnackBar("Selected squad is already full.", AppColors.rose500);
                                return;
                              }

                              // submit (LOGIC: tidak diubah)
                              setModalState(() => isSubmitting = true);
                              try {
                                final resp = await _service.addPlayerToSquad(selected.id, playerId);
                                if (resp['success'] == true) {
                                  // Tutup modal SEGERA supaya user tidak terjebak loading
                                  Navigator.pop(dialogCtx);

                                  // Update quick local UI setelah modal tertutup
                                  final idx = _squads.indexWhere((s) => s.id == chosenSquadId);
                                  if (idx != -1) {
                                    setState(() {
                                      _squads[idx].playerCount = (_squads[idx].playerCount) + 1;
                                    });
                                  }

                                  // Tampilkan notifikasi sukses (context halaman utama masih valid)
                                  _showSnackBar(resp['message'] ?? "Player added to squad!", AppColors.emerald600);

                                  // Refresh data utama (tetap tunggu agar UI sinkron)
                                  await _refreshSquads();
                                } else {
                                  // tetap di modal, re-enable actions
                                  setModalState(() => isSubmitting = false);
                                  _showSnackBar(resp['error'] ?? "Failed to add player", AppColors.rose500);
                                }
                              } catch (e) {
                                setModalState(() => isSubmitting = false);
                                _showSnackBar("Error: $e", AppColors.rose500);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.slate900,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: isSubmitting
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

}
