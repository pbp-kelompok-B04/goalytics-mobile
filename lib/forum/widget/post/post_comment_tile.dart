import 'package:flutter/material.dart';
import 'package:goalytics_mobile/forum/models/forum_models.dart';
import 'package:goalytics_mobile/forum/widget/post/post_helpers.dart';
import 'package:goalytics_mobile/forum/widget/post/post_like_button.dart';

class PostCommentTile extends StatelessWidget {
  const PostCommentTile({
    super.key,
    required this.comment,
    required this.onLike,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleReplies,
    required this.collapsedReplies,
    this.depth = 0,
  });

  final ForumComment comment;
  final ValueChanged<ForumComment> onLike;
  final ValueChanged<ForumComment> onReply;
  final ValueChanged<ForumComment> onEdit;
  final ValueChanged<ForumComment> onDelete;
  final void Function(int id) onToggleReplies;
  final Set<int> collapsedReplies;
    final int depth;

  @override
  Widget build(BuildContext context) {
    final hasReplies = comment.replies.isNotEmpty;
    final collapsed = collapsedReplies.contains(comment.id);
    return Container(
      margin: EdgeInsets.only(left: depth * 16.0, bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildPostAvatar(comment.user, comment.avatar, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            comment.user,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '•',
                          style: TextStyle(color: Color(0xFFCBD5E1)),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          postTimeAgo(comment.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment.content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PostLikeButton(
                isLiked: comment.isLiked,
                count: comment.likeCount,
                onTap: () => onLike(comment),
              ),
              TextButton.icon(
                onPressed: () => onReply(comment),
                icon: const Icon(Icons.reply_rounded, size: 16),
                label: const Text(
                  'Reply',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
              if (comment.isOwner) ...[
                _IconAction(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit',
                  onTap: () => onEdit(comment),
                ),
                _IconAction(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete',
                  color: const Color(0xFFEF4444),
                  onTap: () => onDelete(comment),
                ),
              ],
            ],
          ),
          if (hasReplies) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => onToggleReplies(comment.id),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                collapsed
                    ? 'Show replies (${comment.replies.length})'
                    : 'Hide replies (${comment.replies.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            if (!collapsed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: comment.replies
                      .map(
                        (r) => PostCommentTile(
                          comment: r,
                          onLike: onLike,
                          onReply: onReply,
                          onEdit: onEdit,
                          onDelete: onDelete,
                          onToggleReplies: onToggleReplies,
                          collapsedReplies: collapsedReplies,
                          depth: depth + 1,
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? const Color(0xFF0F172A)).withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (color ?? const Color(0xFF0F172A)).withOpacity(0.1),
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color ?? const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}
