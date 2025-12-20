import 'package:flutter/material.dart';
import 'package:goalytics_mobile/menu.dart';
import 'package:goalytics_mobile/screens/comparison/comparison_screen.dart';
import 'package:goalytics_mobile/screens/rumour/rumour_list.dart';
import 'package:goalytics_mobile/screens/profile/my_profile_page.dart';
import 'package:goalytics_mobile/screens/match_prediction/match_prediction.dart';
import 'package:goalytics_mobile/screens/discussion/forum_home_screen.dart';
import 'package:goalytics_mobile/screens/discussion/post_detail_screen.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  int _getCurrentIndex(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route == null) return 0;

    final String? routeName = route.settings.name;

    if (context.findAncestorWidgetOfExactType<MyHomePage>() != null) return 0;
    if (context.findAncestorWidgetOfExactType<MyProfilePage>() != null) return 1;
    if (context.findAncestorWidgetOfExactType<MatchPredictionPage>() != null) return 2;
    if (context.findAncestorWidgetOfExactType<ForumHomeScreen>() != null) return 3;
    if (context.findAncestorWidgetOfExactType<PostDetailScreen>() != null) return 3;
    if (context.findAncestorWidgetOfExactType<ComparisonScreen>() != null) return 4;
    if (context.findAncestorWidgetOfExactType<RumourListPage>() != null) return 5;

    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index == _getCurrentIndex(context)) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const MyHomePage(title: "Dashboard");
        break;
      case 1:
        nextScreen = const MyProfilePage();
        break;
      case 2:
        nextScreen = MatchPredictionPage();
        break;
      case 3:
        nextScreen = ForumHomeScreen(withSidebar: false);
        break;
      case 4:
        nextScreen = const ComparisonScreen();
        break;
      case 5:
        nextScreen = const RumourListPage();
        break;
      default:
        nextScreen = const MyHomePage(title: "Dashboard");
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => nextScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _getCurrentIndex(context),
      onTap: (index) => _onItemTapped(index, context),
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Profile",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology_outlined),
          activeIcon: Icon(Icons.psychology),
          label: "Prediction",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.forum_outlined),
          activeIcon: Icon(Icons.forum),
          label: "Forum",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.compare_arrows),
          activeIcon: Icon(Icons.compare_arrows),
          label: "Compare",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz),
          activeIcon: Icon(Icons.swap_horiz),
          label: "Rumours",
        ),
      ],
    );
  }
}