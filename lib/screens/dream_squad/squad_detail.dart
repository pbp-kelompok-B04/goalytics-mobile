// lib/screens/dream_squad/squad_detail.dart
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goalytics_mobile/service/dream_squad_service.dart';
import 'package:goalytics_mobile/models/dream_squad_models.dart';
import 'package:goalytics_mobile/service/api_config.dart';
import 'package:goalytics_mobile/screens/dream_squad/edit_squad.dart';
import 'package:goalytics_mobile/screens/dream_squad/player_detail.dart';


class AppColors {
  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate900 = Color(0xFF0F172A);
  static const indigo50 = Color(0xFFEEF2FF);
  static const indigo600 = Color(0xFF4F46E5);
  static const amber50 = Color(0xFFFFFBEB);
  static const amber200 = Color(0xFFFDE68A);
  static const amber700 = Color(0xFFB45309);
  static const rose50 = Color(0xFFFFF1F2);
  static const rose200 = Color(0xFFFECDD3);
  static const rose700 = Color(0xFFBE123C);
}

class SquadDetailPage extends StatefulWidget {
  final int squadId;

  const SquadDetailPage({super.key, required this.squadId});

  @override
  State<SquadDetailPage> createState() => _SquadDetailPageState();
}

class _SquadDetailPageState extends State<SquadDetailPage> {
  late DreamSquadService _service;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  // pastikan konstanta ini 22 sesuai permintaan
  static const int MAX_PLAYERS = 22;

  @override
  void initState() {
    super.initState();
    _service = DreamSquadService(context.read<CookieRequest>(), baseUrl: ApiConfig.baseUrl);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await _service.getSquadDetail(widget.squadId);
      if (mounted) {
        setState(() {
          _data = response; // Simpan response mentah
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_data == null || _data?['success'] == false) {
      return Scaffold(body: Center(child: Text(_data?['error'] ?? "Data not found.")));
    }

    // Ambil data sesuai key di Django squad_detail_api
    final info = _data?['squad_info'] ?? {};
    final stats = _data?['squad_stats'] ?? {};
    final players = _data?['current_players'] as List<dynamic>? ?? [];

    // Ambil data kapasitas dari API (gunakan fallback ke konstanta MAX_PLAYERS)
    // Jika kamu ingin *memaksa* agar selalu 22 tanpa peduli apa yang dikembalikan API,
    // ubah baris berikut jadi: final int maxCap = MAX_PLAYERS;
    final int maxCap = MAX_PLAYERS;

    final int playerCount = stats['player_count'] is int
        ? stats['player_count']
        : (stats['player_count'] is double)
        ? (stats['player_count'] as double).toInt()
        : (stats['player_count'] is String)
        ? int.tryParse(stats['player_count']) ?? 0
        : 0;

    // Logika Validasi: Ambil langsung dari hasil perhitungan Django agar sinkron
    bool isSquadFull = info['is_full'] ?? (playerCount >= maxCap);
    bool isValid = info['is_valid'] ?? false;

    final width = MediaQuery.of(context).size.width;
    int statColumns = 1;
    if (width > 1200) statColumns = 3;
    else if (width > 800) statColumns = 2;
    else statColumns = 1;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.slate600),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(''), // kosongkan karena header di body
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header + actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(info['name'] ?? 'Unnamed Squad', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.slate900)),
                        const SizedBox(height: 6),
                        // tampilkan playerCount / maxCap yang benar
                        Text('Squad Analysis & Player Overview • $playerCount / $maxCap', style: const TextStyle(color: AppColors.slate500)),
                        const SizedBox(height: 18),
                        // small summary row under header
                        Row(
                          children: [
                            _compactChip(Icons.group, 'Total ${playerCount}', null),
                            const SizedBox(width: 8),
                            _compactChip(Icons.timeline, 'Avg xG ${stats['avg_xg'] ?? 0}', null),
                            const SizedBox(width: 8),
                            _compactChip(Icons.calendar_today, 'Avg Age ${stats['avg_age'] ?? 0}', null),
                          ],
                        )
                      ],
                    ),
                  ),

                  // Right: Edit (--- BACK BUTTON DIHAPUS ---)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SquadFormPage(squadId: widget.squadId, initialName: info['name']))).then((_) => _loadData()),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit Squad', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.slate50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          elevation: 4,
                        ),
                      ),
                      // tombol Back di bawah Edit dihapus sesuai permintaan
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              // Alert Section
              if (isSquadFull) _buildAlert("Squad Capacity: Full ($playerCount/$maxCap)", AppColors.amber50, AppColors.amber200, AppColors.amber700, "⚠️"),
              if (!isValid && players.isNotEmpty) _buildAlert("Tactical Requirement: Must include GK, DF, MF, FW.", AppColors.rose50, AppColors.rose200, AppColors.rose700, "❌"),

              const SizedBox(height: 18),

              // Statistics Grid (responsive)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: statColumns,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.4,
                children: [
                  _buildStatCard("Total Players", "$playerCount/$maxCap", Icons.people_outline, AppColors.indigo50, AppColors.indigo600),
                  _buildStatCard("Gls + Ast", "${stats['total_goals_assists'] ?? 0}", Icons.flash_on, const Color(0xFFF0FDF4), Colors.green),
                  _buildStatCard("Avg xG", "${stats['avg_xg'] ?? 0}", Icons.bar_chart, const Color(0xFFFFF7ED), Colors.orange),
                  _buildStatCard("Pass Accuracy", "${stats['avg_pass'] ?? 0}%", Icons.swap_horiz, AppColors.amber50, AppColors.amber200),
                  _buildStatCard("Def. Actions", "${stats['avg_def_actions'] ?? 0}", Icons.shield_outlined, const Color(0xFFEFF6FF), Colors.blue),
                  _buildStatCard("Avg Age", "${stats['avg_age'] ?? 0}", Icons.access_time, const Color(0xFFFAF5FF), Colors.purple),
                ],
              ),

              const SizedBox(height: 28),

              // Roster section
              _buildRosterSection(players),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactChip(IconData icon, String label, Color? bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.slate200)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.slate100), child: Icon(icon, size: 14, color: AppColors.slate600)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.slate600, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.slate200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 6))]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate400, letterSpacing: 1.0)),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.slate900)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAlert(String message, Color bg, Color border, Color text, String icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, border: Border.all(color: border), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(color: text, fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildRosterSection(List<dynamic> players) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.slate200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Players", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.slate900)),
          const SizedBox(height: 6),
          const Text("Detailed list of players currently in this squad.", style: TextStyle(fontSize: 13, color: AppColors.slate500)),
          const SizedBox(height: 18),
          if (players.isEmpty)
            _buildEmptyState()
          else
            LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;
              final cross = width > 900 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisExtent: 92,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final p = players[index];
                  return _buildPlayerItem(p);
                },
              );
            })
        ],
      ),
    );
  }

  Widget _buildPlayerItem(dynamic p) {
    // ambil id dengan aman (bisa int, double atau String)
    int? playerId;
    try {
      final raw = p['id'];
      if (raw is int) playerId = raw;
      else if (raw is double) playerId = raw.toInt();
      else if (raw is String) playerId = int.tryParse(raw);
    } catch (_) {
      playerId = null;
    }

    return InkWell(
      onTap: playerId == null
          ? null
          : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerDetailPage(playerId: playerId!),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.slate100),
        ),
        child: Row(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: p['image_url'] != null && p['image_url'].toString().isNotEmpty
                    ? Image.network(p['image_url'], fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                  return Center(child: Text(p['name'] != null && p['name'].toString().length >= 2 ? p['name'].toString().substring(0, 2).toUpperCase() : "--", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate400)));
                })
                    : Center(child: Text(p['name'] != null && p['name'].toString().length >= 2 ? p['name'].toString().substring(0, 2).toUpperCase() : "--", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate400))),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(p['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900)),
                  const SizedBox(height: 4),
                  Text(p['club_name'] ?? "Free Agent", style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.slate50, border: Border.all(color: AppColors.slate200), borderRadius: BorderRadius.circular(8)),
              child: Text(p['position'] ?? "", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate600)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.slate400, size: 20),
          ],
        ),
      ),
    );
  }


  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.slate200, style: BorderStyle.solid)),
      child: Column(
        children: [
          const Text("No players found in this squad.", style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SquadFormPage(squadId: widget.squadId))).then((_) => _loadData()),
            child: const Text("+ Add your first player", style: TextStyle(color: AppColors.indigo600, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  bool _checkPositionValidation(List<dynamic> players) {
    final positions = players.map((p) => p['position'].toString().toUpperCase()).toSet();
    return positions.contains('GK') && positions.contains('DF') && positions.contains('MF') && positions.contains('FW');
  }
}
