import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import 'forum_meta.dart';

class ForumPostCard extends StatelessWidget {
  const ForumPostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLike,
  });

  final ForumPost post;
  final VoidCallback onTap;
  final VoidCallback onLike;

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 8)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE2E8F0),
              backgroundImage: post.avatar != null ? NetworkImage(post.avatar!) : null,
              child: post.avatar == null
                  ? Text(post.author.isNotEmpty ? post.author[0].toUpperCase() : '?')
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(post.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(post.league, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ),
            IconButton(
              onPressed: onLike,
              icon: Icon(
                post.isLiked ? Icons.favorite : Icons.favorite_border,
                color: post.isLiked ? Colors.red : Colors.grey,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text(post.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(post.content, maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Row(children: [
            ForumMeta(icon: Icons.comment, label: '${post.commentCount}'),
            const SizedBox(width: 12),
            ForumMeta(icon: Icons.favorite, label: '${post.likeCount}'),
            const Spacer(),
            Text(_formatTime(post.createdAt), style: const TextStyle(fontSize: 12)),
          ])
        ]),
      ),
    );
  }
}
