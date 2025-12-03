import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import '../../../widgets/forum/forum_detail/forum_detail_card.dart';
import '../../../widgets/forum/forum_detail/forum_detail_time_helper.dart';

class ForumDetailHeader extends StatelessWidget {
  const ForumDetailHeader({super.key, required this.post});
  final ForumPost post;

  @override
  Widget build(BuildContext context) {
    return ForumDetailCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundImage:
                post.avatar != null ? NetworkImage(post.avatar!) : null,
            child: post.avatar == null ? Text(post.author[0]) : null,
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(post.author, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${post.league} • ${formatTime(post.createdAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ])
        ]),
        const SizedBox(height: 12),
        Text(post.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(post.content),
        if (post.mediaUrl != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(post.mediaUrl!, fit: BoxFit.cover),
          )
        ]
      ]),
    );
  }
}
