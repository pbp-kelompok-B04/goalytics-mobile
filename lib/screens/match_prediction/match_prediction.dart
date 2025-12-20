import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goalytics_mobile/models/match_model.dart';
import 'package:goalytics_mobile/widgets/left_drawer.dart';
import 'package:goalytics_mobile/screens/match_prediction/match_detail_screen.dart';
import 'package:goalytics_mobile/service/api_config.dart';
import 'package:goalytics_mobile/screens/match_prediction/match_form_screen.dart';

class MatchPredictionPage extends StatefulWidget {
  const MatchPredictionPage({super.key});

  @override
  State<MatchPredictionPage> createState() => _MatchPredictionPageState();
}

class _MatchPredictionPageState extends State<MatchPredictionPage> {
  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    // 👇 Panggil fungsi cek role
    Future.microtask(() => _fetchUserRole());
  }

  // 👇 Fungsi Baru
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
    // Sesuaikan path URL dengan yang ada di urls.py Django
    final response = await request.get('${ApiConfig.baseUrl}/matchprediction/json/');

    // Konversi JSON response menjadi list object Match
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
      appBar: AppBar(
        title: const Text('Match Predictions'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      floatingActionButton: _isManager ? FloatingActionButton(
        onPressed: () async {
          // Buka halaman Form
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MatchFormScreen(),
            ),
          );
          // Refresh halaman setelah balik (agar match baru muncul)
          setState(() {});
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,

      body: FutureBuilder(
        future: fetchMatches(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    "No matches available.",
                    style: TextStyle(color: Color(0xff59A5D8), fontSize: 20),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  Match match = snapshot.data![index];
                  // Format tanggal sederhana
                  String date = match.fields.matchDatetime.toString().substring(0, 16);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: InkWell(
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${match.fields.homeClubName ?? 'TBD'} vs ${match.fields.awayClubName ?? 'TBD'}",
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(date),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.stadium, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(match.fields.venue),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}