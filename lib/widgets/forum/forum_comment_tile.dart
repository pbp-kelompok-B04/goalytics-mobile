import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import 'package:goalytics_mobile/widgets/forum/forum_time.dart';

class ForumCommentTile extends StatelessWidget {
  const ForumCommentTile({
    super.key,
    required this.comment,
    required this.onLike,
    required this.onReply,
    this.depth = 0,
  });

  final ForumComment comment;
  final ValueChanged<ForumComment> onLike;
  final ValueChanged<ForumComment> onReply;
  final int depth;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: depth * 16, bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE2E8F0),
                backgroundImage:
                    comment.avatar != null ? NetworkImage(comment.avatar!) : null,
                child: comment.avatar == null
                    ? Text(
                        comment.user.isNotEmpty
                            ? comment.user[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.user,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatForumTime(comment.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => onLike(comment),
                icon: Icon(
                  comment.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: comment.isLiked
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              TextButton(
                onPressed: () => onReply(comment),
                child: const Text('Reply'),
              ),
              const SizedBox(width: 6),
              Text(
                '${comment.likeCount} likes',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty)
            Column(
              children: comment.replies
                  .map(
                    (r) => ForumCommentTile(
                      comment: r,
                      onLike: onLike,
                      onReply: onReply,
                      depth: depth + 1,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
