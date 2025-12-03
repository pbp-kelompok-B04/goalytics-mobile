import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import '../../../widgets/forum/forum_detail/forum_detail_meta.dart';
import '../../../widgets/forum/forum_detail/forum_detail_time_helper.dart';

class ForumDetailCommentCard extends StatelessWidget {
  const ForumDetailCommentCard({
    super.key,
    required this.comment,
    required this.onLike,
  });

  final ForumComment comment;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: _box,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            backgroundImage:
                comment.avatar != null ? NetworkImage(comment.avatar!) : null,
            child: comment.avatar == null ? Text(comment.user[0]) : null,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(comment.user)),
          IconButton(
            icon: Icon(
              comment.isLiked ? Icons.favorite : Icons.favorite_border,
              color: comment.isLiked ? Colors.red : Colors.grey,
            ),
            onPressed: onLike,
          )
        ]),
        const SizedBox(height: 4),
        Text(comment.content),
        const SizedBox(height: 6),
        Row(
          children:[
            ForumDetailMeta(icon: Icons.favorite, label: '${comment.likeCount}'),
            const Spacer(),
            Text(formatTime(comment.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        )
      ]),
    );
  }

  static const _box = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(14)),
  );
}
