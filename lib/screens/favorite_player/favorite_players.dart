import 'package:flutter/material.dart';

class FavoritePlayersPage extends StatelessWidget {
  const FavoritePlayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorite Players")),
      body: const Center(child: Text("Favorite Players Page")),
    );
  }
}
