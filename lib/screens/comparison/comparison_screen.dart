import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Pastikan fl_chart ada di pubspec.yaml
import '/models/comparison_model.dart';
import '/service/player_service.dart';
import '/service/comparison_service.dart';
import 'package:goalytics_mobile/widgets/left_drawer.dart';
import 'package:goalytics_mobile/screens/comparison/comparison_history_screen.dart';

// ==========================================
// PALETTE WARNA (Sesuai Tailwind Slate & Emerald)
// ==========================================
class AppColors {
  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);

  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);

  static const amber50 = Color(0xFFFFFBEB);
  static const amber200 = Color(0xFFFDE68A);
  static const amber600 = Color(0xFFD97706);

  static const rose500 = Color(0xFFF43F5E);
  static const blue500 = Color(0xFF3B82F6);
}

class ComparisonScreen extends StatefulWidget {
  final int? player1Id;
  final int? player2Id;
  final int? comparisonId;
  final String? notes;

  const ComparisonScreen({
    super.key,
    this.player1Id,
    this.player2Id,
    this.comparisonId,
    this.notes,
  });

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  // State Variables
  Player? player1;
  Player? player2;
  List<Player> suggestions1 = [];
  List<Player> suggestions2 = [];
  
  bool isLoading = false;
  bool loadingPlayers = false;
  bool hasResult = false;
  Map<String, dynamic>? result;

  final p1Controller = TextEditingController();
  final p2Controller = TextEditingController();
  final notesController = TextEditingController();
  
  CookieRequest? _request;

  @override
  void initState() {
    super.initState();
    if (widget.notes != null) {
      notesController.text = widget.notes!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _request = Provider.of<CookieRequest>(context, listen: false);
    
    // Auto Load Logic
    if (widget.comparisonId != null) {
      _loadComparisonDetails();
    } else if (widget.player1Id != null && widget.player2Id != null) {
      _loadPlayersByIds();
    }
  }

  @override
  void dispose() {
    p1Controller.dispose();
    p2Controller.dispose();
    notesController.dispose();
    super.dispose();
  }

  // ================= LOGIC LOADERS (Sama seperti sebelumnya) =================

  Future<void> _loadPlayersByIds() async {
    if (_request == null) return;
    setState(() => loadingPlayers = true);
    try {
      if (widget.player1Id != null) {
        final p1 = await PlayerService.getPlayerById(widget.player1Id!, _request!);
        setState(() { player1 = p1; p1Controller.text = p1.name; });
      }
      if (widget.player2Id != null) {
        final p2 = await PlayerService.getPlayerById(widget.player2Id!, _request!);
        setState(() { player2 = p2; p2Controller.text = p2.name; });
      }
      if (player1 != null && player2 != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        await comparePlayers();
      }
    } catch (e) {
      print('Err loading players: $e');
    } finally {
      setState(() => loadingPlayers = false);
    }
  }

  Future<void> _loadComparisonDetails() async {
    if (_request == null || widget.comparisonId == null) return;
    
    setState(() => loadingPlayers = true);
    
    try {
      // 1. Panggil Service
      final data = await ComparisonService.getComparisonDetail(
        widget.comparisonId!,
        _request!,
      );
      
      // 2. Ambil data 'comparison' dari response JSON
      final comparison = data['comparison']; // Pastikan sesuai dengan views.py
      
      if (comparison != null) {
        // 3. Load Player 1
        final player1Id = comparison['player1_id'];
        if (player1Id != null) {
          final p1 = await PlayerService.getPlayerById(player1Id, _request!);
          setState(() {
            player1 = p1;
            p1Controller.text = p1.name;
          });
        }
        
        // 4. Load Player 2
        final player2Id = comparison['player2_id'];
        if (player2Id != null) {
          final p2 = await PlayerService.getPlayerById(player2Id, _request!);
          setState(() {
            player2 = p2;
            p2Controller.text = p2.name;
          });
        }
        
        // 5. Set Notes
        final notes = comparison['notes'] ?? '';
        notesController.text = notes;
        
        // 6. Auto Compare (Trigger)
        if (player1 != null && player2 != null) {
          // Beri jeda sedikit agar UI render dulu
          await Future.delayed(const Duration(milliseconds: 500));
          await comparePlayers();
        }
      }
    } catch (e) {
      print('Error loading comparison details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load details: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loadingPlayers = false);
      }
    }
  }

  // ================= LOGIC SEARCH & COMPARE =================

  Future<void> searchPlayer(String query, int num) async {
    if (query.length < 2) {
      setState(() { num == 1 ? suggestions1.clear() : suggestions2.clear(); });
      return;
    }
    try {
      final players = await PlayerService.searchPlayers(query);
      setState(() { num == 1 ? suggestions1 = players : suggestions2 = players; });
    } catch (e) { print(e); }
  }

  void selectPlayer(Player player, int num) {
    setState(() {
      if (num == 1) {
        player1 = player;
        p1Controller.text = player.name;
        suggestions1.clear();
      } else {
        player2 = player;
        p2Controller.text = player.name;
        suggestions2.clear();
      }
      // Reset result jika player berubah
      hasResult = false;
      result = null;
    });
  }

  void clearPlayer(int num) {
    setState(() {
      if (num == 1) {
        player1 = null;
        p1Controller.clear();
        suggestions1.clear();
      } else {
        player2 = null;
        p2Controller.clear();
        suggestions2.clear();
      }
      hasResult = false;
      result = null;
    });
  }

  Future<void> comparePlayers() async {
    if (player1 == null || player2 == null) return;
    setState(() => isLoading = true);
    
    try {
      // Panggil API compare (tanpa perlu token auth krn public di HTML pun public)
      final data = await PlayerService.comparePlayers(
        player1Id: player1!.id, 
        player2Id: player2!.id
      );
      
      setState(() {
        result = data;
        hasResult = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= LOGIC SAVE (FIXED) =================

  Future<void> saveOrUpdateComparison() async {
    // 1. Validasi
    if (_request == null || player1 == null || player2 == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select both players first")),
        );
      }
      return;
    }

    // 2. Loading...
    setState(() => isLoading = true); 

    try {
      // 3. Panggil API
      final success = await ComparisonService.saveComparison(
        request: _request!,
        player1Id: player1!.id,
        player2Id: player2!.id,
        notes: notesController.text,
        comparisonId: widget.comparisonId,
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      if (success) {
        // === PERBAIKAN DI SINI ===
        // Jangan pakai pop(), tapi paksa pindah ke History Screen
        // Ini mencegah layar putih jika stack navigasi kosong
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ComparisonHistoryScreen(),
          ),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.comparisonId != null 
                ? "Comparison updated successfully!" 
                : "Comparison saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to save comparison"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  // ================= UI BUILDER =================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(), // Unfocus keyboard
      child: Scaffold(
        backgroundColor: AppColors.slate50, // Matches HTML bg-slate-50
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.slate700),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),

          title: const Text(
            "Player Comparison",
            style: TextStyle(color: AppColors.slate900, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: AppColors.slate200, height: 1.0),
          ),
        ),
        drawer: LeftDrawer(),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER SECTION
                  const Text(
                    "COMPARISON",
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, 
                      color: AppColors.slate500, letterSpacing: 1.2
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Compare two players",
                    style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800, 
                      color: AppColors.slate900, height: 1.2
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Select two players to evaluate their performance. If they share the same position, a radar chart will appear.",
                    style: TextStyle(fontSize: 16, color: AppColors.slate500, height: 1.5),
                  ),
                  
                  const SizedBox(height: 32),

                  // PLAYER INPUT SECTION (Card Style)
                  _buildPlayerInputCard(1),
                  
                  // VS Badge
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: AppColors.slate200),
                        boxShadow: const [
                          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 4, offset: Offset(0, 2))
                        ],
                      ),
                      child: const Text(
                        "VS",
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate500),
                      ),
                    ),
                  ),

                  _buildPlayerInputCard(2),

                  const SizedBox(height: 32),

                  // COMPARE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (player1 != null && player2 != null) ? comparePlayers : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.slate900,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.slate900.withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: AppColors.slate200,
                      ),
                      child: const Text(
                        "Compare Players",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // RESULTS SECTION
                  if (hasResult && result != null)
                    _buildResultsUI()
                  else if (!isLoading)
                    _buildPlaceholderUI(),

                  const SizedBox(height: 24),
                  
                  // HISTORY LINK
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ComparisonHistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text("View Comparison History"),
                      style: TextButton.styleFrom(foregroundColor: AppColors.slate500),
                    ),
                  ),

                  // SAVE BUTTON SECTION
                  if (hasResult && result != null) ...[
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 10, offset: Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Save Comparison",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.slate900),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Save this to your history for future reference.",
                            style: TextStyle(color: AppColors.slate500),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: showSaveModal,
                              icon: const Icon(Icons.save_outlined),
                              label: Text(widget.comparisonId != null ? "Update Comparison" : "Save Comparison"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.emerald600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
            
            // Loading Overlay
            if (isLoading || loadingPlayers)
              Container(
                color: AppColors.slate900.withOpacity(0.6),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 16),
                        Text("Processing...", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.slate700))
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET HELPER: PLAYER CARD =================

  Widget _buildPlayerInputCard(int num) {
    final player = num == 1 ? player1 : player2;
    final controller = num == 1 ? p1Controller : p2Controller;
    final suggestions = num == 1 ? suggestions1 : suggestions2;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.03), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Player $num",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.slate900),
              ),
              if (player != null)
                 IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.slate400),
                  onPressed: () => clearPlayer(num),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
            ],
          ),
          const SizedBox(height: 4),
          const Text("Search and select a player.", style: TextStyle(fontSize: 13, color: AppColors.slate500)),
          const SizedBox(height: 16),
          
          if (player == null) ...[
            TextField(
              controller: controller,
              onChanged: (v) => searchPlayer(v, num),
              decoration: InputDecoration(
                hintText: "Type player name...",
                hintStyle: const TextStyle(color: AppColors.slate400),
                filled: true,
                fillColor: AppColors.slate50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.slate200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.slate200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.slate400),
                ),
              ),
            ),
            if (suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.slate200),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: suggestions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.slate100),
                  itemBuilder: (ctx, idx) {
                    final p = suggestions[idx];
                    return ListTile(
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text("${p.club} • ${p.position}", style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                      onTap: () => selectPlayer(p, num),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
              ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: num == 1 ? AppColors.blue500.withOpacity(0.1) : AppColors.rose500.withOpacity(0.1),
                    child: Text(
                      player.position,
                      style: TextStyle(
                        color: num == 1 ? AppColors.blue500 : AppColors.rose500,
                        fontWeight: FontWeight.bold,
                        fontSize: 12
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate900)),
                        Text("${player.club}", style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  // ================= WIDGET HELPER: RESULTS & PLACEHOLDER =================

  Widget _buildPlaceholderUI() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200, style: BorderStyle.solid), // Dashed border susah di native flutter tanpa package external
      ),
      child: const Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 48, color: AppColors.slate400),
          SizedBox(height: 16),
          Text(
            "Comparison results will appear here once two players are selected.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.slate500),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsUI() {
    // Parsing Data (Aman dari null)
    final stats1 = Map<String, dynamic>.from(result?['player1_stats'] ?? {});
    final stats2 = Map<String, dynamic>.from(result?['player2_stats'] ?? {});
    final maxValues = Map<String, dynamic>.from(result?['max_values'] ?? {});
    final bool samePosition = result?['same_position'] == true;

    // Parsing Radar Data
    final radarLabels = List<String>.from(result?['radar_labels'] ?? []);
    final radarData1 = List<dynamic>.from(result?['radar_data1'] ?? []).map((e) => (e as num).toDouble()).toList();
    final radarData2 = List<dynamic>.from(result?['radar_data2'] ?? []).map((e) => (e as num).toDouble()).toList();
    final radarMax = List<dynamic>.from(result?['radar_max'] ?? []).map((e) => (e as num).toDouble()).toList();

    return Column(
      children: [
        // 1. STATS COMPARISON
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.slate200),
            boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const Text("Stats Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.slate900)),
               const SizedBox(height: 20),
               // Menggunakan Layout Row untuk membagi dua kolom statistik
               Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Expanded(child: _buildStatsList(player1!, stats1, maxValues, AppColors.blue500)),
                   const SizedBox(width: 24),
                   Expanded(child: _buildStatsList(player2!, stats2, maxValues, AppColors.rose500)),
                 ],
               )
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 2. RADAR CHART
        if (samePosition && radarLabels.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.slate200),
              boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                const Text("Radar Comparison", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.slate900)),
                const SizedBox(height: 8),
                Text("Role-specific metrics comparison", style: TextStyle(fontSize: 12, color: AppColors.slate500)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 300,
                  child: RadarChart(
                    RadarChartData(
                      radarBackgroundColor: Colors.transparent,
                      radarBorderData: const BorderSide(color: AppColors.slate200),
                      gridBorderData: const BorderSide(color: AppColors.slate200, width: 0.5),
                      tickCount: 4,
                      ticksTextStyle: const TextStyle(color: Colors.transparent),
                      titleTextStyle: const TextStyle(color: AppColors.slate600, fontSize: 10, fontWeight: FontWeight.bold),
                      getTitle: (index, angle) {
                        return RadarChartTitle(text: _formatLabel(radarLabels[index]), angle: angle, positionPercentageOffset: 0.1);
                      },
                      dataSets: [
                        RadarDataSet(
                          fillColor: AppColors.blue500.withOpacity(0.2),
                          borderColor: AppColors.blue500,
                          entryRadius: 2,
                          dataEntries: _normalizeRadarData(radarData1, radarMax),
                        ),
                        RadarDataSet(
                          fillColor: AppColors.rose500.withOpacity(0.2),
                          borderColor: AppColors.rose500,
                          entryRadius: 2,
                          dataEntries: _normalizeRadarData(radarData2, radarMax),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendItem(AppColors.blue500, player1!.name),
                    const SizedBox(width: 16),
                    _legendItem(AppColors.rose500, player2!.name),
                  ],
                )
              ],
            ),
          )
      ],
    );
  }

  // ================= HELPER FUNCTIONS =================

  Widget _buildStatsList(Player p, Map<String, dynamic> stats, Map<String, dynamic> maxValues, Color color) {
    // Generate items based on position (Logic sama persis dgn sebelumnya)
    final items = _getStatsForPosition(p.position, stats, maxValues);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Kecil per Player
        Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 12),
        
        ...items.map((item) {
          final val = item['value'] as double;
          final max = item['maxValue'] as double;
          final percent = (max > 0 ? val / max : 0.0).clamp(0.0, 1.0);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['label'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.slate500)),
                    Text("${val.toStringAsFixed(1)}${item['suffix']}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.slate900)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: AppColors.slate100,
                    color: color,
                    minHeight: 6,
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  List<RadarEntry> _normalizeRadarData(List<double> data, List<double> maxVals) {
    return List.generate(data.length, (i) {
      final max = maxVals[i];
      return RadarEntry(value: max > 0 ? data[i] / max : 0);
    });
  }

  Widget _legendItem(Color c, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate600))
      ],
    );
  }

  String _formatLabel(String raw) {
    // Format label radar biar rapi (Goals, Assists, etc)
    return raw.replaceAll('_', ' ').split(' ').map((e) => e.isEmpty ? '' : '${e[0].toUpperCase()}${e.substring(1)}').join(' ');
  }

   List<Map<String, dynamic>> _getStatsForPosition(String pos, Map<String, dynamic> stats, Map<String, dynamic> max) {
    final keys = <String>[];
    
    if (pos == 'GK') {
      keys.addAll([
        'goals', 'assists', 'saves', 'save_percentage', 
        'clean_sheets', 'clean_sheet_percentage' // Ditambahkan clean_sheet_percentage
      ]);
    } else if (pos == 'DF') {
      keys.addAll([
        'goals', 'assists', 'tackles', 'tackles_won', 
        'challenges_won', 'challenges_attempted', // Ditambahkan dari flutter 1
        'blocks', 'clearances'
      ]);
    } else if (pos == 'MF') {
      keys.addAll([
        'goals', 'assists', 
        'Progressive_Carries', 'Progressive_Passes', 'Progressive_Receptions', // Ditambahkan Carries & Receptions
        'passes_completed', 'passes_attempted', // Ditambahkan Attempted
        'pass_accuracy', 'xag' // Ditambahkan xag
      ]);
    } else {
      // FW & Default
      keys.addAll(['goals', 'assists', 'xg', 'npxg', 'xag']); 
    }

    return keys.map((k) => {
      'label': _formatLabel(k),
      'value': (stats[k] is num) ? (stats[k] as num).toDouble() : 0.0,
      'maxValue': (max[k] is num) ? (max[k] as num).toDouble() : 1.0,
      'suffix': (k.contains('percentage') || k.contains('accuracy')) ? '%' : ''
    }).toList();
  }

  // ================= MODAL SAVE (FIXED PADDING & LOGIC) =================

  void showSaveModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Wajib agar bottom sheet bisa naik
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          top: 24, left: 24, right: 24,
          // Ini trik agar modal naik saat keyboard muncul
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Save Comparison", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.slate900)),
            const SizedBox(height: 8),
            const Text("Add optional notes for this comparison.", style: TextStyle(color: AppColors.slate500)),
            const SizedBox(height: 24),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "E.g. Bellingham is better at progressive passes...",
                filled: true,
                fillColor: AppColors.slate50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.slate200)),
                      foregroundColor: AppColors.slate600
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Tutup modal dulu
                      saveOrUpdateComparison(); // Baru save
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.slate900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(widget.comparisonId != null ? "Update" : "Save"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}