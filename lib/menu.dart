import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===================== HEADER =====================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xff1c2341),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.sports_soccer, color: Colors.black),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      "Goalytics",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Text(
                      "Your football companion",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Hi, KareemMalik 👋",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),

                    const Text(
                      "Welcome back to your dashboard",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Info Cards Row
                    Row(
                      children: [
                        _infoCard("AVAILABLE TOOLS", "6", Icons.build),
                        const SizedBox(width: 12),
                        _infoCard("LAST ACTIVE", "Now", Icons.access_time),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Profile Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: const [
                          CircleAvatar(
                            backgroundColor: Colors.teal,
                            radius: 20,
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "KareemMalik",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Admin"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===================== FEATURES =====================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Features",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              _featureCard(
                title: "Player Comparison",
                subtitle: "Compare player stats and insights side by side",
                icon: Icons.people_alt_outlined,
              ),

              _featureCard(
                title: "Match Prediction",
                subtitle:
                    "Predict match outcomes and analyze performance data",
                icon: Icons.bar_chart_outlined,
              ),

              _featureCard(
                title: "Transfer Rumour",
                subtitle:
                    "Find out the latest transfer rumour happening in football",
                icon: Icons.swap_horiz_outlined,
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // ===================== BOTTOM NAVIGATION =====================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        selectedItemColor: const Color(0xff1c2341),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined), label: "Predictions"),
          BottomNavigationBarItem(
              icon: Icon(Icons.newspaper), label: "Rumours"),
        ],
      ),
    );
  }

  // ===================== SMALL WIDGETS =====================
  Widget _infoCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.orange),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 34, color: Colors.pink),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
