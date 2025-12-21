import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goalytics_mobile/models/match_model.dart';
import 'package:goalytics_mobile/screens/match_prediction/match_detail_screen.dart';
import 'package:goalytics_mobile/service/api_config.dart';
import 'package:goalytics_mobile/screens/match_prediction/match_form_screen.dart';
import 'package:goalytics_mobile/widgets/bottom_nav.dart';

class MatchPredictionPage extends StatefulWidget {
  const MatchPredictionPage({super.key});

  @override
  State<MatchPredictionPage> createState() => _MatchPredictionPageState();
}

class _MatchPredictionPageState extends State<MatchPredictionPage> {
  bool _isManager = false;

  // Warna tema diambil dari LeftDrawer agar konsisten
  final Color _themeColor = const Color(0xff1c2341);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchUserRole());
  }

  Future<void> _fetchUserRole() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('${ApiConfig.baseUrl}/matchprediction/get-role/');
      if (mounted) {
        setState(() {
          _isManager = response['is_manager'] ?? false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching role: $e");
    }
  }

  Future<List<Match>> fetchMatches(CookieRequest request) async {
    final response = await request.get('${ApiConfig.baseUrl}/matchprediction/json/');
    List<Match> listMatch = [];
    for (var d in response) {
      if (d != null) {
        listMatch.add(Match.fromJson(d));
      }
    }
    return listMatch;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.grey[50], // Background agak abu terang biar card putih pop-up
      // 1. AppBar Transparan & Icon Hitam (Theme Color)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const BottomNav(),

      floatingActionButton: _isManager
          ? FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MatchFormScreen(),
            ),
          );
          setState(() {}); // Refresh setelah create match
        },
        backgroundColor: _themeColor,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text("New Match", style: TextStyle(color: Colors.white)),
      )
          : null,

      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Section (Typography Modern)
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bagian Teks (Kiri)
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Football Match\nPrediction",
                            style: TextStyle(
                              fontSize: 28, // Sedikit disesuaikan agar muat
                              fontWeight: FontWeight.w800,
                              color: _themeColor,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Predict the score, beat the odds, and rule the leaderboard!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bagian Visual/Icon (Kanan)
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: _themeColor.withOpacity(0.1), // Background kotak tipis
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.insights, // Icon grafik/prediksi
                          size: 40,
                          color: _themeColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 2. Section Title "Upcoming Games"
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 20, color: _themeColor),
                    const SizedBox(width: 8),
                    Text(
                      "Upcoming Games",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _themeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // List Matches
                FutureBuilder(
                  future: fetchMatches(request),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: CircularProgressIndicator(),
                      ));
                    } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.sports_soccer, size: 50, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            const Text("No upcoming matches.", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    } else {
                      // ListView di dalam Column harus pake shrinkWrap & physics ini
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (_, index) {
                          Match match = snapshot.data![index];
                          return _buildMatchCard(context, match);
                        },
                      );
                    }
                  },
                ),

                // Extra space di bawah agar tidak ketutupan FAB
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 4, 5, 6. Custom Card Widget untuk Match
  Widget _buildMatchCard(BuildContext context, Match match) {
    // Format tanggal sederhana: YYYY-MM-DD HH:MM
    String rawDate = match.fields.matchDatetime.toString();
    String date = rawDate.length > 16 ? rawDate.substring(0, 16).replaceAll('T', ' • ') : rawDate;

    String homeTeam = match.fields.homeClubName ?? 'TBD';
    String awayTeam = match.fields.awayClubName ?? 'TBD';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetailScreen(match: match),
              ),
            );
            if (result == true) {
              setState(() {});
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header Card: Date & Venue (Small, Grey)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 10),
                    Container(width: 1, height: 12, color: Colors.grey[300]), // Separator
                    const SizedBox(width: 10),
                    Icon(Icons.stadium, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        match.fields.venue,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Main Content: Team A vs Team B
                Row(
                  children: [
                    // Home Team (Expanded agar nama panjang turun ke bawah)
                    Expanded(
                      child: Column(
                        children: [
                          _buildTeamAvatar(homeTeam), // Inisial Klub
                          const SizedBox(height: 8),
                          Text(
                            homeTeam,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _themeColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // VS Badge
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "VS",
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),

                    // Away Team
                    Expanded(
                      child: Column(
                        children: [
                          _buildTeamAvatar(awayTeam), // Inisial Klub
                          const SizedBox(height: 8),
                          Text(
                            awayTeam,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _themeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget kecil untuk membuat Avatar inisial (misal: "Arsenal" -> "A")
  Widget _buildTeamAvatar(String teamName) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          teamName.isNotEmpty ? teamName[0].toUpperCase() : "?",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _themeColor.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}