// lib/screens/dream_squad/squad_detail.dart
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goalytics_mobile/dream_squad/services/dream_squad_service.dart';
import 'package:goalytics_mobile/dream_squad/models/dream_squad_models.dart';
import '../../../main/services/api_config.dart';
import 'package:goalytics_mobile/dream_squad/screens/edit_squad.dart';
import 'package:goalytics_mobile/dream_squad/screens/player_detail.dart';

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
          _data = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading squad detail: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_data == null || _data?['success'] == false) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: BackButton(color: AppColors.slate600)),
        body: Center(child: Text(_data?['error'] ?? "Data not found.")),
      );
    }

    final info = _data?['squad_info'] ?? {};
    final stats = _data?['squad_stats'] ?? {};
    final players = _data?['current_players'] as List<dynamic>? ?? [];

    final int maxCap = MAX_PLAYERS;
    final int playerCount = _parseInt(stats['player_count']);

    bool isSquadFull = info['is_full'] ?? (playerCount >= maxCap);
    bool isValid = info['is_valid'] ?? false;

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 900;
    final bool isTablet = screenWidth > 600 && screenWidth <= 900;

    // responsive stat columns logic
    int statColumns = 1;
    if (screenWidth > 1200) statColumns = 3;
    else if (screenWidth > 900) statColumns = 2;
    else statColumns = 1;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.slate600), onPressed: () => Navigator.pop(context)),
        title: const Text(''),
        actions: [
          // show edit action on wide; on small we'll show FAB too
          if (isWide)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: () => _openEdit(),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Squad', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.slate900,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: isWide
          ? null
          : FloatingActionButton(
        onPressed: () => _openEdit(),
        backgroundColor: AppColors.indigo600,
        child: const Icon(Icons.edit),
        tooltip: 'Edit squad',
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header area — stack vertically on small screens
              LayoutBuilder(builder: (context, constraints) {
                final width = constraints.maxWidth;
                final bool narrow = width < 700;
                return narrow ? _buildHeaderColumn(info, stats, playerCount, maxCap) : _buildHeaderRow(info, stats, playerCount, maxCap);
              }),

              const SizedBox(height: 18),

              // Alerts
              if (isSquadFull) _buildAlert("Squad Capacity: Full ($playerCount/$maxCap)", AppColors.amber50, AppColors.amber200, AppColors.amber700, "⚠️"),
              if (!isValid && players.isNotEmpty) _buildAlert("Tactical Requirement: Must include GK, DF, MF, FW.", AppColors.rose50, AppColors.rose200, AppColors.rose700, "❌"),

              const SizedBox(height: 16),

              // Statistics grid (responsive)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: statColumns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.6,
                children: [
                  _buildStatCard("Total Players", "$playerCount/$maxCap", Icons.people_outline, AppColors.indigo50, AppColors.indigo600),
                  _buildStatCard("Gls + Ast", "${stats['total_goals_assists'] ?? 0}", Icons.flash_on, const Color(0xFFF0FDF4), Colors.green),
                  _buildStatCard("Avg xG", "${stats['avg_xg'] ?? 0}", Icons.bar_chart, const Color(0xFFFFF7ED), Colors.orange),
                  _buildStatCard("Pass Accuracy", "${stats['avg_pass'] ?? 0}%", Icons.swap_horiz, AppColors.amber50, AppColors.amber200),
                  _buildStatCard("Def. Actions", "${stats['avg_def_actions'] ?? 0}", Icons.shield_outlined, const Color(0xFFEFF6FF), Colors.blue),
                  _buildStatCard("Avg Age", "${stats['avg_age'] ?? 0}", Icons.access_time, const Color(0xFFFAF5FF), Colors.purple),
                ],
              ),

              const SizedBox(height: 22),

              // Roster section
              _buildRosterSection(players, isWide: isWide, isTablet: isTablet),
            ],
          ),
        ),
      ),
    );
  }

  // --- header variants ---
  Widget _buildHeaderRow(Map<String, dynamic> info, Map<String, dynamic> stats, int playerCount, int maxCap) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: title + subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(info['name'] ?? 'Unnamed Squad', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.slate900)),
              const SizedBox(height: 6),
              Text('Squad Analysis • $playerCount / $maxCap', style: const TextStyle(color: AppColors.slate500)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _compactChip(Icons.group, 'Total $playerCount', null),
                  const SizedBox(width: 8),
                  _compactChip(Icons.timeline, 'Avg xG ${stats['avg_xg'] ?? 0}', null),
                  const SizedBox(width: 8),
                  _compactChip(Icons.calendar_today, 'Avg Age ${stats['avg_age'] ?? 0}', null),
                ],
              )
            ],
          ),
        ),

        // Right: edit action
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () => _openEdit(),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit Squad', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.slate900,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderColumn(Map<String, dynamic> info, Map<String, dynamic> stats, int playerCount, int maxCap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(info['name'] ?? 'Unnamed Squad', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.slate900)),
        const SizedBox(height: 6),
        Text('Squad Analysis • $playerCount / $maxCap', style: const TextStyle(color: AppColors.slate500)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _compactChip(Icons.group, 'Total $playerCount', null),
          _compactChip(Icons.timeline, 'Avg xG ${stats['avg_xg'] ?? 0}', null),
          _compactChip(Icons.calendar_today, 'Avg Age ${stats['avg_age'] ?? 0}', null),
        ]),
      ],
    );
  }

  void _openEdit() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => SquadFormPage(squadId: widget.squadId, initialName: _data?['squad_info']?['name'])))
        .then((_) => _loadData());
  }

  // --- utility UI pieces ---
  Widget _compactChip(IconData icon, String label, Color? bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.slate200)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.slate200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate400, letterSpacing: 0.8)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.slate900)),
            ]),
          )
        ],
      ),
    );
  }

  Widget _buildAlert(String message, Color bg, Color border, Color text, String icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, border: Border.all(color: border), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [Text(icon, style: const TextStyle(fontSize: 18)), const SizedBox(width: 10), Expanded(child: Text(message, style: TextStyle(color: text, fontWeight: FontWeight.w600)))]),
    );
  }

  Widget _buildRosterSection(List<dynamic> players, {required bool isWide, required bool isTablet}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.slate200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 6, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Players", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.slate900)),
        const SizedBox(height: 6),
        const Text("Detailed list of players currently in this squad.", style: TextStyle(fontSize: 13, color: AppColors.slate500)),
        const SizedBox(height: 12),
        if (players.isEmpty)
          _buildEmptyState()
        else
          LayoutBuilder(builder: (context, constraints) {
            // responsive columns depending on available width
            final w = constraints.maxWidth;
            int cross = 1;
            if (w > 1100) cross = 3;
            else if (w > 700) cross = 2;
            else cross = 1;

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
              itemBuilder: (context, index) => _buildPlayerItem(players[index]),
            );
          }),
      ]),
    );
  }

  Widget _buildPlayerItem(dynamic p) {
    int? playerId = _parseIntDynamic(p['id']);

    return InkWell(
      onTap: playerId == null
          ? null
          : () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerDetailPage(playerId: playerId))).then((_) => _loadData());
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.slate100), color: Colors.white),
        child: Row(children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: p['image_url'] != null && p['image_url'].toString().isNotEmpty
                  ? Image.network(p['image_url'], fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                return Center(child: Text(_initials(p['name']), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate400)));
              })
                  : Center(child: Text(_initials(p['name']), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate400))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(p['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900)),
              const SizedBox(height: 4),
              Text(p['club_name'] ?? "Free Agent", style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.slate50, border: Border.all(color: AppColors.slate200), borderRadius: BorderRadius.circular(8)),
            child: Text(p['position'] ?? "", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate600)),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.slate400, size: 20),
        ]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26),
      decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.slate200)),
      child: Column(children: [
        const Text("No players found in this squad.", style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SquadFormPage(squadId: widget.squadId))).then((_) => _loadData()),
          child: const Text("+ Add your first player", style: TextStyle(color: AppColors.indigo600, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ]),
    );
  }

  // --- helpers ---
  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static int? _parseIntDynamic(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static String _initials(dynamic name) {
    final s = (name ?? '').toString().trim();
    if (s.isEmpty) return '--';
    final parts = s.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return s.substring(0, 1).toUpperCase();
    final initials = parts.map((p) => p[0]).take(2).join().toUpperCase();
    return initials;
  }

  bool _checkPositionValidation(List<dynamic> players) {
    final positions = players.map((p) => p['position'].toString().toUpperCase()).toSet();
    return positions.contains('GK') && positions.contains('DF') && positions.contains('MF') && positions.contains('FW');
  }
}
