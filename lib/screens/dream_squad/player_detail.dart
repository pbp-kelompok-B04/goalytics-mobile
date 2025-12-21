// lib/screens/dream_squad/player_detail.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../service/dream_squad_service.dart';
import '../../models/dream_squad_models.dart';
import '../../service/api_config.dart';

// Ringkasan warna (mirip AppColors di dream_squad.dart)
class _LocalColors {
  static const slate50 = Color(0xFFF8FAFC);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate500 = Color(0xFF64748B);
  static const slate700 = Color(0xFF334155);
  static const slate900 = Color(0xFF0F172A);
  static const emerald600 = Color(0xFF059669);
  static const sky500 = Color(0xFF0EA5E9);
  static const rose500 = Color(0xFFF43F5E);
}

class PlayerDetailPage extends StatefulWidget {
  final int playerId;
  const PlayerDetailPage({Key? key, required this.playerId}) : super(key: key);

  @override
  State<PlayerDetailPage> createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> {
  late CookieRequest _request;
  late DreamSquadService _service;
  late Future<PlayerModel> _futurePlayer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _request = Provider.of<CookieRequest>(context, listen: false);
    _service = DreamSquadService(_request, baseUrl: ApiConfig.baseUrl);
    _futurePlayer = _service.getPlayerDetail(widget.playerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _LocalColors.slate50,
      // HAPUS drawer supaya tidak ada side-scroll / side menu
      appBar: AppBar(
        backgroundColor: Colors.white, // navbar putih
        elevation: 0,
        // hanya tombol back di kiri atas
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _LocalColors.slate900),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
        ),
        title: const Text(
          'Player Detail',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<PlayerModel>(
        future: _futurePlayer,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Error: ${snapshot.error}", textAlign: TextAlign.center),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("No player data."));
          }

          final p = snapshot.data!;
          return SingleChildScrollView(
            // pastikan hanya vertikal, hindari side scroll
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(p, context),
                const SizedBox(height: 20),
                _sectionTitle("Attacking Output"),
                const SizedBox(height: 10),
                _responsiveStats([
                  _statCard("Goals", p.attacking.goals.toString(), _LocalColors.rose500),
                  _statCard("Assists", p.attacking.assists.toString(), _LocalColors.sky500),
                  _statCard("xG", p.attacking.xg.toStringAsFixed(1), _LocalColors.emerald600),
                ], context),
                const SizedBox(height: 20),
                _sectionTitle("Passing & Progression"),
                const SizedBox(height: 10),
                _responsiveStats([
                  _statCard("Pass Accuracy", "${(p.passing.accuracy).toStringAsFixed(1)}%", _LocalColors.slate700),
                  _statCard("Passes Completed", p.passing.completed.toString(), _LocalColors.slate500),
                ], context),
                const SizedBox(height: 20),
                _sectionTitle("Defensive Actions"),
                const SizedBox(height: 10),
                _responsiveStats([
                  _statCard("Tackles Won", p.defensive.tacklesWon.toString(), _LocalColors.rose500),
                  _statCard("Clearances", p.defensive.clearances.toString(), _LocalColors.slate500),
                ], context),
                const SizedBox(height: 20),
                _sectionTitle("Advanced Metrics"),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _LocalColors.slate200),
                  ),
                  child: const Text("No additional advanced metrics available."),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(PlayerModel p, BuildContext context) {
    final initials = p.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _LocalColors.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: _LocalColors.slate100,
            backgroundImage: (p.imageUrl != null && p.imageUrl!.isNotEmpty) ? NetworkImage(p.imageUrl!) : null,
            child: (p.imageUrl == null || p.imageUrl!.isEmpty)
                ? Text(initials, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(p.positionDisplay, style: const TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: _LocalColors.slate100,
                    ),
                    Text("•", style: TextStyle(color: _LocalColors.slate200)),
                    Flexible(child: Text("${p.clubName} • ${p.nation}", style: TextStyle(color: _LocalColors.slate500))),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Age: ${p.age}", style: TextStyle(color: _LocalColors.slate500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  /// Responsive layout: gunakan Wrap agar kartu menyesuaikan lebar layar.
  Widget _responsiveStats(List<Widget> items, BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // target item width: di mobile satu kolom ~ full, di tablet/desktop 2-3 kolom
    double targetWidth;
    if (screenWidth >= 1200) {
      targetWidth = (screenWidth - 60) / 3; // 3 columns
    } else if (screenWidth >= 800) {
      targetWidth = (screenWidth - 48) / 2; // 2 columns
    } else {
      targetWidth = screenWidth - 48; // single column on narrow screen
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map((w) => SizedBox(
        width: targetWidth.clamp(200, screenWidth),
        child: w,
      ))
          .toList(),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _LocalColors.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
