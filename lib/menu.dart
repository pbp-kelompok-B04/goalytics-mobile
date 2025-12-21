import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:goalytics_mobile/widgets/bottom_nav.dart';
import 'package:goalytics_mobile/screens/comparison/comparison_screen.dart';
import 'package:goalytics_mobile/screens/rumour/rumour_list.dart';
import 'package:goalytics_mobile/screens/profile/explore_profile_page.dart';
import 'package:goalytics_mobile/screens/favorite_player/favorite_players.dart';
import 'package:goalytics_mobile/screens/match_prediction/match_prediction.dart';
import 'package:goalytics_mobile/screens/discussion/forum_home_screen.dart';
import 'package:goalytics_mobile/service/api_config.dart';
import 'package:goalytics_mobile/models/ProfileEntry.dart';
import 'package:goalytics_mobile/screens/profile/my_profile_page.dart';

const Color primaryDark = Color(0xFF0F172A);

String proxiedImageUrl(String originalUrl) {
  final raw = originalUrl.trim();
  if (raw.isEmpty) return "";

  if (raw.contains("/users/image-proxy/")) return raw;

  final base = ApiConfig.baseUrl.endsWith('/')
      ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
      : ApiConfig.baseUrl;

  final uri = Uri.tryParse(raw);
  if (uri == null) return "";

  final absolute =
      uri.hasScheme ? raw : (raw.startsWith('/') ? "$base$raw" : "$base/$raw");

  if (absolute.startsWith(base)) return absolute;

  return "$base/users/image-proxy/?url=${Uri.encodeComponent(absolute)}";
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? username;
  ProfileEntry? profile;
  bool isLoadingUser = true;

  Future<void> fetchProfile() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get("${ApiConfig.baseUrl}/users/api/me/");
      if (response['status'] == true && response['data'] != null) {
        final data = response['data'];
        setState(() {
          profile = ProfileEntry.fromJson(data);
          username = profile?.username;
          isLoadingUser = false;
        });
      } else {
        setState(() {
          isLoadingUser = false;
        });
        print("Failed to fetch profile: ${response['message']}");
      }
    } catch (e) {
      setState(() {
        isLoadingUser = false;
      });
      print("Error fetching profile: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: primaryDark,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.grey[100],
      body: isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER CARD
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyProfilePage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryDark,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryDark.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            foregroundImage: (profile
                                        ?.profilePicture.isNotEmpty ??
                                    false)
                                ? NetworkImage(
                                    proxiedImageUrl(profile!.profilePicture),
                                  )
                                : null,
                            child: (profile?.profilePicture.isEmpty ?? true)
                                ? const Icon(Icons.person, size: 32)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hi, ${username ?? 'GoalyticsUser'} 👋",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Welcome back to Goalytics",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// STATS
                  Row(
                    children: [
                      _statCard("Available Tools", "6", Icons.extension),
                      const SizedBox(width: 12),
                      _statCard("Last Active", "Now", Icons.access_time),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Quick Actions",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _featureCard(
                    title: "Favorite Players",
                    description: "Save and track your favorite football stars.",
                    icon: Icons.favorite,
                  ),
                  _featureCard(
                    title: "Match Prediction",
                    description:
                        "Predict upcoming matches and test your intuition.",
                    icon: Icons.psychology,
                  ),
                  _featureCard(
                    title: "Discussion Forum",
                    description: "Discuss matches, players, and more!",
                    icon: Icons.forum,
                  ),
                  _featureCard(
                    title: "Player Comparison",
                    description: "Compare two players head-to-head!",
                    icon: Icons.compare_arrows,
                  ),
                  _featureCard(
                    title: "Transfer Rumours",
                    description: "Check latest football transfer news.",
                    icon: Icons.swap_horiz,
                  ),
                  _featureCard(
                    title: "Find Users",
                    description: "Search and discover other Goalytics users.",
                    icon: Icons.search,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNav(),
    );
  }

  /// STAT CARD WIDGET
  Widget _statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FEATURE CARD WIDGET
  Widget _featureCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (title == "Player Comparison") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ComparisonScreen()),
          );
        } else if (title == "Transfer Rumours") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RumourListPage()),
          );
        } else if (title == "Find Users") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExploreProfilesPage()),
          );
        } else if (title == "Favorite Players") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavoritePlayersPage()),
          );
        } else if (title == "Match Prediction") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MatchPredictionPage()),
          );
        } else if (title == "Discussion Forum") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ForumHomeScreen(withSidebar: false),
            ),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryDark.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}