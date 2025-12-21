// lib/screens/dream_squad/player_detail.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../service/dream_squad_service.dart';
import '../../models/dream_squad_models.dart';
import '../../service/api_config.dart';

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
    // Always refresh the future in didChangeDependencies to ensure fresh data
    _futurePlayer = _service.getPlayerDetail(widget.playerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _LocalColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(Icons.arrow_back, color: _LocalColors.slate700),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Player Detail',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: FutureBuilder<PlayerModel>(
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
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _futurePlayer = _service.getPlayerDetail(widget.playerId);
                });
                await _futurePlayer;
              },
              child: LayoutBuilder(builder: (context, constraints) {
                final width = constraints.maxWidth;
                final bool narrow = width < 700;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header (responsive)
                      narrow ? _buildHeaderColumn(p) : _buildHeaderRow(p),
                      const SizedBox(height: 20),

                      // Sections
                      _sectionTitle("Attacking Output"),
                      const SizedBox(height: 10),
                      _responsiveStats(
                        context,
                        [
                          _statCard("Goals", _safeIntToString(p.attacking.goals), _LocalColors.rose500),
                          _statCard("Assists", _safeIntToString(p.attacking.assists), _LocalColors.sky500),
                          _statCard("xG", _safeNumToFixed(p.attacking.xg, 1), _LocalColors.emerald600),
                        ],
                        constraints,
                      ),
                      const SizedBox(height: 20),

                      _sectionTitle("Passing & Progression"),
                      const SizedBox(height: 10),
                      _responsiveStats(
                        context,
                        [
                          _statCard("Pass Accuracy", _safeNumToFixed(p.passing.accuracy, 1) + "%", _LocalColors.slate700),
                          _statCard("Passes Completed", _safeIntToString(p.passing.completed), _LocalColors.slate500),
                        ],
                        constraints,
                      ),
                      const SizedBox(height: 20),

                      _sectionTitle("Defensive Actions"),
                      const SizedBox(height: 10),
                      _responsiveStats(
                        context,
                        [
                          _statCard("Tackles Won", _safeIntToString(p.defensive.tacklesWon), _LocalColors.rose500),
                          _statCard("Clearances", _safeIntToString(p.defensive.clearances), _LocalColors.slate500),
                        ],
                        constraints,
                      ),
                      const SizedBox(height: 20),

                      _sectionTitle("Advanced Metrics"),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _LocalColors.slate200),
                        ),
                        child: const Text("No additional advanced metrics available."),
                      ),

                      const SizedBox(height: 28),
                    ],
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  // Header variants: Row for wide, Column for narrow
  Widget _buildHeaderRow(PlayerModel p) {
    final initials = _initials(p.name);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _LocalColors.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
      ),
      child: Row(
        children: [
          _avatarWidget(p, radius: 40, initials: initials),
          const SizedBox(width: 16),
          Expanded(
            child: _playerInfoColumn(p),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Age", style: TextStyle(color: _LocalColors.slate500, fontSize: 12)),
              const SizedBox(height: 6),
              Text("${p.age}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeaderColumn(PlayerModel p) {
    final initials = _initials(p.name);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _LocalColors.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
      ),
      child: Column(
        children: [
          _avatarWidget(p, radius: 48, initials: initials),
          const SizedBox(height: 12),
          _playerInfoColumn(p),
          const SizedBox(height: 8),
          Text("Age: ${p.age}", style: TextStyle(color: _LocalColors.slate500)),
        ],
      ),
    );
  }

  Widget _avatarWidget(PlayerModel p, {required double radius, required String initials}) {
    final imageUrl = p.imageUrl;
    final radiusInt = radius;
    return Container(
      width: radiusInt * 2,
      height: radiusInt * 2,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radiusInt.toDouble()), color: _LocalColors.slate100),
      clipBehavior: Clip.hardEdge,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(widthFactor: 1, heightFactor: 1, child: CircularProgressIndicator(value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1) : null));
        },
        errorBuilder: (_, __, ___) {
          return Center(child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, color: _LocalColors.slate700, fontSize: 20)));
        },
      )
          : Center(child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, color: _LocalColors.slate700, fontSize: 20))),
    );
  }

  Widget _playerInfoColumn(PlayerModel p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Chip(label: Text(p.positionDisplay, style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: _LocalColors.slate100),
            Text("•", style: TextStyle(color: _LocalColors.slate200)),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text("${p.clubName} • ${p.nation}", style: TextStyle(color: _LocalColors.slate500), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  /// Responsive stat grid: compute target width based on available width
  Widget _responsiveStats(BuildContext context, List<Widget> items, BoxConstraints constraints) {
    final double total = constraints.maxWidth;
    // padding accounted in parent: we provide targetWidth based on total.
    int columns;
    if (total >= 1200) columns = 3;
    else if (total >= 800) columns = 2;
    else columns = 1;

    final double gap = 12;
    final double targetWidth = (total - (gap * (columns - 1))) / columns;

    return Wrap(
      spacing: gap,
      runSpacing: 12,
      children: items.map((w) {
        final double wwidth = targetWidth.clamp(160, total);
        return SizedBox(width: wwidth, child: w);
      }).toList(),
    );
  }


  Widget _statCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _LocalColors.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 6)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
    );
  }

  // safe numeric helpers
  static String _safeIntToString(dynamic v) {
    if (v == null) return '0';
    if (v is int) return v.toString();
    if (v is double) return v.toInt().toString();
    if (v is String) return int.tryParse(v) != null ? int.tryParse(v)!.toString() : v;
    return v.toString();
  }

  static String _safeNumToFixed(dynamic v, int frac) {
    if (v == null) return (0).toStringAsFixed(frac);
    if (v is int) return v.toDouble().toStringAsFixed(frac);
    if (v is double) return v.toStringAsFixed(frac);
    if (v is String) {
      final d = double.tryParse(v);
      return d != null ? d.toStringAsFixed(frac) : v;
    }
    try {
      final n = num.parse(v.toString());
      return n.toDouble().toStringAsFixed(frac);
    } catch (_) {
      return v.toString();
    }
  }

  static String _initials(String? name) {
    final s = (name ?? '').trim();
    if (s.isEmpty) return '--';
    final parts = s.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return s.substring(0, 1).toUpperCase();
    final initials = parts.map((p) => p[0]).take(2).join().toUpperCase();
    return initials;
  }
}
