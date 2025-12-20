import 'package:flutter/material.dart';
import 'package:goalytics_mobile/menu.dart';
import 'package:goalytics_mobile/screens/comparison/comparison_screen.dart';
import 'package:goalytics_mobile/screens/rumour/rumour_list.dart';
import 'package:goalytics_mobile/screens/profile/my_profile_page.dart';
import 'package:goalytics_mobile/screens/profile/explore_profile_page.dart';
import 'package:goalytics_mobile/screens/match_prediction/match_prediction.dart';
// 👇 PERBAIKAN IMPORT: Mengarah ke nama file yang benar di repo Anda
import 'package:goalytics_mobile/screens/discussion/forum_home_screen.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xff1c2341),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ===================== HEADER =====================
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xff1c2341),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.sports_soccer, color: Colors.black),
                ),
                SizedBox(height: 12),
                Text(
                  "Goalytics",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Your football companion",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          // ===================== MENU ITEMS =====================
          _drawerItem(
            icon: Icons.dashboard_outlined,
            title: "Dashboard",
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const MyHomePage(title: "Dashboard"),
                ),
              );
            },
          ),

          _drawerItem(
            icon: Icons.person_outline,
            title: "My Profile",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyProfilePage(),
                ),
              );
            },
          ),

          _drawerItem(
            icon: Icons.swap_horiz,
            title: "Transfer Rumours",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RumourListPage(),
                ),
              );
            },
          ),

          _drawerItem(
            icon: Icons.favorite,
            title: "Favorite Players",
            onTap: () {},
          ),

          _drawerItem(
            icon: Icons.psychology,
            title: "Match Prediction",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // 👇 HAPUS const DI SINI
                  builder: (context) => MatchPredictionPage(),
                ),
              );
            },
          ),

          _drawerItem(
            icon: Icons.forum,
            title: "Discussion Forum",
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  // 👇 HAPUS const DI SINI & PASTIKAN NAMA CLASS BENAR
                  builder: (_) => ForumHomeScreen(withSidebar: true),
                ),
              );
            },
          ),

          _drawerItem(
            icon: Icons.compare_arrows,
            title: "Player Comparison",
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ComparisonScreen(),
                ),
              );
            },
          ),

          _drawerItem(
            icon: Icons.search,
            title: "Find Users",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExploreProfilesPage(),
                ),
              );
            },
          ),

          const Divider(color: Colors.white24),

          _drawerItem(
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () {},
          ),

          _drawerItem(
            icon: Icons.logout,
            title: "Logout",
            onTap: () {
              // TODO: logout logic
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      onTap: onTap,
      hoverColor: Colors.white10,
    );
  }
}