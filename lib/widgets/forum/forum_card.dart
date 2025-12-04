import 'package:flutter/material.dart';

class ForumCard extends StatelessWidget {
  const ForumCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ForumLoadingCard extends StatelessWidget {
  const ForumLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const ForumCard(
      child: Column(
        children: [
          SizedBox(height: 8),
          CircularProgressIndicator(strokeWidth: 2.4),
          SizedBox(height: 12),
          Text(
            'Loading posts...',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class ForumEmptyCard extends StatelessWidget {
  const ForumEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const ForumCard(
      child: Column(
        children: [
          SizedBox(height: 6),
          Icon(Icons.forum_outlined, size: 32, color: Color(0xFFCBD5E1)),
          SizedBox(height: 10),
          Text(
            'No posts yet. Start the conversation!',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
