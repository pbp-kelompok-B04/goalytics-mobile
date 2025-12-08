import 'package:flutter/material.dart';
import 'package:goalytics_mobile/widgets/left_drawer.dart';
import 'package:goalytics_mobile/screens/rumour_list.dart'; 

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LeftDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

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
              "Features",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // ==== 6 FEATURE CARDS ====
            _featureCard(
              title: "Favorite Players",
              description: "Save and track your favorite soccer players.",
              icon: Icons.favorite,
            ),

            _featureCard(
              title: "Match Prediction",
              description: "Predict upcoming matches and test your skills!",
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
    );
  }

  // ==================================================
  //                FEATURE CARD WIDGET
  // ==================================================
  Widget _featureCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        // ⬇️ LOGIKA BARU: kalau Transfer Rumours, buka RumourListPage
        if (title == "Transfer Rumours") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RumourListPage(),
            ),
          );
        } else {
          // fitur lain tetap pakai FeaturePage dummy
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FeaturePage(title: title),
            ),
          );
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
                        fontSize: 18, 
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
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
//              DUMMY PAGE FOR NAVIGATION
// ==========================================================
class FeaturePage extends StatelessWidget {
  final String title;

  const FeaturePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          "$title Page",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
