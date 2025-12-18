import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import 'package:goalytics_mobile/widgets/post/post_helpers.dart';
import 'package:goalytics_mobile/widgets/post/post_like_button.dart';
import 'package:goalytics_mobile/widgets/post/post_media_preview.dart';

class ForumListCard extends StatelessWidget {
  const ForumListCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLike,
    this.onEdit,
    this.onDelete,
  });

  final ForumPost post;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final mediaUrl = post.attachmentUrl?.isNotEmpty == true
        ? post.attachmentUrl
        : post.mediaUrl;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
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
        child: Stack(
          children: [
            if (post.isAuthor && (onEdit != null || onDelete != null))
              Positioned(
                right: 0,
                top: 0,
                child: Row(
                  children: [
                    if (onEdit != null)
                      _IconButton(
                        icon: Icons.edit_outlined,
                        onTap: onEdit!,
                        tooltip: 'Edit post',
                      ),
                    if (onDelete != null)
                      _IconButton(
                        icon: Icons.delete_outline,
                        onTap: onDelete!,
                        tooltip: 'Delete post',
                        color: const Color(0xFFEF4444),
                      ),
                  ],
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildPostAvatar(post.author, post.avatar, size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                    color: Color(0xFF0F172A),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  postLeagueLabel(post.league),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (mediaUrl != null) ...[
                  PostMediaPreview(url: mediaUrl),
                  const SizedBox(height: 8),
                ],
                Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('•',
                            style: TextStyle(color: Color(0xFFCBD5E1))),
                        const SizedBox(width: 6),
                        Text(
                          postTimeAgo(post.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        PostLikeButton(
                          isLiked: post.isLiked,
                          count: post.likeCount,
                          onTap: onLike,
                        ),
                        const SizedBox(width: 14),
                        Row(
                          children: [
                            const Icon(Icons.article_outlined,
                                size: 18, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 6),
                            Text(
                              '${post.commentCount}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final btn = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(left: 6),
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
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
  }
}
