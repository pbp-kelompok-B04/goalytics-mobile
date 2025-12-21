import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:goalytics_mobile/widgets/left_drawer.dart';
import 'package:goalytics_mobile/widgets/bottom_nav.dart';
import 'package:goalytics_mobile/screens/comparison/comparison_screen.dart';
import 'package:goalytics_mobile/screens/rumour/rumour_list.dart';
import 'package:goalytics_mobile/screens/profile/explore_profile_page.dart';
import 'package:goalytics_mobile/screens/dream_squad/dream_squad.dart';
import 'package:goalytics_mobile/screens/match_prediction/match_prediction.dart';
import 'package:goalytics_mobile/screens/discussion/forum_home_screen.dart';

const Color primaryDark = Color(0xFF0F172A);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String? username;
  bool isLoadingUser = true;

  Future<void> fetchUsername() async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
      "https://jefferson-tirza-goalytics.pbp.cs.ui.ac.id/auth/user-info/",
    );

    setState(() {
      username = response['username'];
      isLoadingUser = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  void _navigateBottomBar(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DreamSquadPage()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MatchPredictionPage()));
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ForumHomeScreen(username: username ?? 'GoalyticsUser'),
          ),
        );
        break;
      case 4:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ComparisonScreen()));
        break;
      case 5:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const RumourListPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LeftDrawer(),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryDark,
        iconTheme: const IconThemeData(
          color: Colors.white, // ← ini yang bikin icon ☰ putih
        ),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
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
                  Container(
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
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, $username 👋",
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
                      ],
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
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _featureCard(
                    title: "Dream Squad",
                    description: "Save and manage your dream squad.",
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

      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
      ),
    );
  }

  /// STAT CARD
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// FEATURE CARD
  Widget _featureCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (title == "Player Comparison") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ComparisonScreen()));
        } else if (title == "Transfer Rumours") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RumourListPage()));
        } else if (title == "Find Users") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ExploreProfilesPage()));
        } else if (title == "Dream Squad") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const DreamSquadPage()));
        } else if (title == "Match Prediction") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MatchPredictionPage()));
        } else if (title == "Discussion Forum") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ForumHomeScreen(username: username ?? 'GoalyticsUser'),
            ),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(description,
                        style: const TextStyle(color: Colors.grey)),
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
