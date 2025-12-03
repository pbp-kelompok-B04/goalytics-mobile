import 'package:flutter/material.dart';
import 'forum_card.dart';

class ForumEmptyCard extends StatelessWidget {
  const ForumEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const ForumCard(
      child: Column(
        children: [
          Icon(Icons.forum_outlined, size: 32, color: Colors.grey),
          SizedBox(height: 12),
          Text('No posts yet. Start a discussion.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
