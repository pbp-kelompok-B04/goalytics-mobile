import 'package:flutter/material.dart';
import 'package:goalytics_mobile/menu.dart';
import 'package:goalytics_mobile/screens/comparison/comparison_screen.dart';
import 'package:goalytics_mobile/screens/rumour/rumour_list.dart';
import 'package:goalytics_mobile/screens/profile/explore_profile_page.dart';
import 'package:goalytics_mobile/screens/favorite_player/favorite_players.dart';
import 'package:goalytics_mobile/screens/match_prediction/match_prediction.dart';
import 'package:goalytics_mobile/screens/forum_home_screen.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "Favorites",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology),
          label: "Prediction",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.forum),
          label: "Forum",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.compare_arrows),
          label: "Compare",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz),
          label: "Rumours",
        ),
      ],
    );
  }
}
