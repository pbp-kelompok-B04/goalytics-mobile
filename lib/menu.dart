import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:goalytics_mobile/widgets/left_drawer.dart';
import 'package:goalytics_mobile/widgets/bottom_nav.dart';
import 'package:goalytics_mobile/screens/comparison/comparison_screen.dart';
import 'package:goalytics_mobile/screens/rumour/rumour_list.dart';
import 'package:goalytics_mobile/screens/profile/explore_profile_page.dart';
import 'package:goalytics_mobile/screens/favorite_player/favorite_players.dart';
import 'package:goalytics_mobile/screens/match_prediction/match_prediction.dart';
import 'package:goalytics_mobile/screens/discussion/discussion_forum.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        // Home → stay here
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FavoritePlayersPage()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MatchPredictionPage()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DiscussionForumPage()));
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      // MAIN CONTENT
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Goalytics Indonesia",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Indonesia’s #1 Source for Soccer Stats, News, and Predictions.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            _featureCard(
              title: "Favorite Players",
              description: "Save and track your favorite football stars.",
              icon: Icons.favorite,
            ),
            _featureCard(
              title: "Match Prediction",
              description: "Predict upcoming matches and test your intuition.",
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

      // BOTTOM NAVBAR
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
      ),
    );
  }

  Widget _featureCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        if (title == "Player Comparison") {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ComparisonScreen()));
        } else if (title == "Transfer Rumours") {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const RumourListPage()));
        } else if (title == "Find Users") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ExploreProfilesPage()));
        } else if (title == "Favorite Players") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const FavoritePlayersPage()));
        } else if (title == "Match Prediction") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MatchPredictionPage()));
        } else if (title == "Discussion Forum") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const DiscussionForumPage()));
        }
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blueAccent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
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
