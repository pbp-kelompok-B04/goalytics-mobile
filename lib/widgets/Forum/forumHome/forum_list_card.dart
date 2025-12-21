import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum_models.dart';
import 'package:goalytics_mobile/screens/profile/explore_profile_page.dart';
import 'package:goalytics_mobile/widgets/Forum/post/post_helpers.dart';
import 'package:goalytics_mobile/widgets/Forum/post/post_like_button.dart';
import 'package:goalytics_mobile/widgets/Forum/post/post_media_preview.dart';

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

    const slate900 = Color(0xFF0F172A);
    const slate600 = Color(0xFF475569);
    const slate500 = Color(0xFF64748B);
    const slate200 = Color(0xFFE2E8F0);
    const slate100 = Color(0xFFF1F5F9);
    const slate50  = Color(0xFFF8FAFC);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24), // rounded-3xl
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24), // p-6
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // rounded-3xl
          border: Border.all(color: slate200), // border-slate-200
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000), // shadow-sm (very subtle)
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: profileAvatar(
                    imageUrl: post.avatar ?? '',
                    fallbackText: post.author,
                    radius: 24,
                  ),
                ),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        
                        padding: EdgeInsets.only(
                          right: (post.isAuthor && (onEdit != null || onDelete != null)) 
                              ? 64.0 
                              : 0
                        ),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,    
                          runSpacing: 4, 
                          children: [
                            
                            Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 17, 
                                fontWeight: FontWeight.w700,
                                color: slate900,
                                height: 1.2,
                              ),
                            ),
                           
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: slate50,
                                borderRadius: BorderRadius.circular(100), 
                                border: Border.all(color: slate200),
                              ),
                              child: Text(
                                postLeagueLabel(post.league),
                                style: const TextStyle(
                                  fontSize: 11, 
                                  fontWeight: FontWeight.w600, 
                                  color: slate600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      if (mediaUrl != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16), // rounded-2xl
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: slate200),
                            ),
                            child: PostMediaPreview(url: mediaUrl),
                          ),
                        ),
                      ],

                      
                      const SizedBox(height: 8),
                      Text(
                        post.content,
                        maxLines: 3, 
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14, 
                          color: slate600,
                          height: 1.5, 
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    post.author,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: slate600,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Text('•',
                                      style: TextStyle(color: Color(0xFFCBD5E1))),
                                ),
                                Text(
                                  postTimeAgo(post.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: slate500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          
                          Row(
                            children: [
                              PostLikeButton(
                                isLiked: post.isLiked,
                                count: post.likeCount,
                                onTap: onLike,
                              ),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 18,
                                    color: Color(0xFF94A3B8), 
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${post.commentCount}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
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

           
            if (post.isAuthor && (onEdit != null || onDelete != null))
              Positioned(
                right: 1, 
                top: 1,
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
                        color: const Color(0xFFF43F5E), 
                        bgColor: const Color(0xFFFFF1F2), 
                      ),
                  ],
                ),
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
    this.bgColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? color;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    final btn = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: bgColor ?? const Color(0xFFF1F5F9).withOpacity(0.5), 
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (color ?? const Color(0xFF0F172A)).withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          size: 13,
          color: color ?? const Color(0xFF64748B), 
        ),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
  }
}