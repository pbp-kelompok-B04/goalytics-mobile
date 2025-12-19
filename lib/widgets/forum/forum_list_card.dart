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

  // Konstanta warna Tailwind Slate untuk konsistensi
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color rose500 = Color(0xFFF43F5E);

  @override
  Widget build(BuildContext context) {
    final mediaUrl = post.attachmentUrl?.isNotEmpty == true
        ? post.attachmentUrl
        : post.mediaUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // rounded-3xl
        border: Border.all(color: slate200),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05), // shadow-sm
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24), // p-6
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Avatar Section (Left) ---
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: buildPostAvatar(post.author, post.avatar, size: 48),
                    ),

                    // --- Content Section (Right) ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header: Title & League Badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontSize: 18, // text-lg
                                    fontWeight: FontWeight.w600, // font-semibold
                                    color: slate900,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // League Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: slate100,
                                  borderRadius: BorderRadius.circular(99), // rounded-full
                                  border: Border.all(color: slate200),
                                ),
                                child: Text(
                                  postLeagueLabel(post.league),
                                  style: const TextStyle(
                                    fontSize: 12, // text-xs
                                    fontWeight: FontWeight.w500, // font-medium
                                    color: slate600,
                                  ),
                                ),
                              ),
                              // Spacing for absolute buttons if author
                              if (post.isAuthor) const SizedBox(width: 20),
                            ],
                          ),

                          const SizedBox(height: 12), // space-y-3

                          // 2. Media (Jika ada)
                          if (mediaUrl != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16), // rounded-2xl
                              child: PostMediaPreview(url: mediaUrl),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // 3. Post Content Text
                          Text(
                            post.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14, // text-sm
                              color: slate600,
                              height: 1.6, // leading-relaxed
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 4. Footer: Meta & Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Author & Time
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        post.author,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: slate600,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6),
                                      child: Text('•', style: TextStyle(color: slate300)),
                                    ),
                                    Text(
                                      postTimeAgo(post.createdAt),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: slate500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Like & Comment Counts
                              Row(
                                children: [
                                  // Like Button (Custom Widget assumed to be adaptable)
                                  PostLikeButton(
                                    isLiked: post.isLiked,
                                    count: post.likeCount,
                                    onTap: onLike,
                                    // Pastikan widget ini mendukung custom color jika perlu,
                                    // atau biarkan defaultnya. Di CSS: text-rose-500
                                  ),
                                  const SizedBox(width: 16),
                                  // Comment Indicator
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 18,
                                        color: slate400,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${post.commentCount}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: slate500,
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
                    ),
                  ],
                ),
              ),

              // --- Absolute Action Buttons (Top Right) ---
              // Sesuai CSS: absolute right-6 top-6
              if (post.isAuthor && (onEdit != null || onDelete != null))
                Positioned(
                  right: 12, // Sedikit disesuaikan agar tidak terlalu menempel tepi Container
                  top: 12,
                  child: Row(
                    children: [
                      if (onEdit != null)
                        _IconButton(
                          icon: Icons.edit_outlined,
                          onTap: onEdit!,
                          tooltip: 'Edit post',
                          bgColor: Colors.white.withOpacity(0.8),
                          borderColor: slate200,
                          iconColor: slate500,
                        ),
                      if (onDelete != null)
                        _IconButton(
                          icon: Icons.delete_outline_rounded,
                          onTap: onDelete!,
                          tooltip: 'Delete post',
                          bgColor: const Color(0xFFFFF1F2), // rose-50
                          borderColor: const Color(0xFFFFE4E6), // rose-100
                          iconColor: rose500,
                        ),
                    ],
                  ),
                ),
            ],
          ),
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
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12), // rounded-2xl look
            border: Border.all(color: borderColor),
          ),
          child: Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
        ),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
  }
}