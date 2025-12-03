import 'package:flutter/material.dart';
import 'forum_card.dart';

class ForumLoadingCard extends StatelessWidget {
  const ForumLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const ForumCard(
      child: Column(
        children: [
          CircularProgressIndicator(strokeWidth: 2),
          SizedBox(height: 12),
          Text('Loading posts...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
