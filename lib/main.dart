import 'package:flutter/material.dart';
import 'package:goalytics_mobile/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    Provider<CookieRequest>(
      create: (_) => CookieRequest(),
      child: const GoalyticsApp(),
    ),
  );
}

class GoalyticsApp extends StatelessWidget {
  const GoalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Goalytics",
      home: const LoginPage(),
    );
  }
}
