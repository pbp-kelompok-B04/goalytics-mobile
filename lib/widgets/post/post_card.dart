import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import 'package:goalytics_mobile/widgets/post/post_helpers.dart';
import 'package:goalytics_mobile/widgets/post/post_like_button.dart';
import 'package:goalytics_mobile/widgets/post/post_media_preview.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onToggleLike,
    this.busy = false,
  });

  final ForumPost post;
  final VoidCallback onToggleLike;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final mediaUrl = post.attachmentUrl?.isNotEmpty == true
        ? post.attachmentUrl
        : post.mediaUrl;
    return Container(
      width: double.infinity,
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
      child: Column(
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
                      children: [
                        Text(
                          post.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            postLeagueLabel(post.league),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
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
                    const SizedBox(height: 10),
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (mediaUrl != null) ...[
            PostMediaPreview(url: mediaUrl),
            const SizedBox(height: 12),
          ],
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              PostLikeButton(
                isLiked: post.isLiked,
                count: post.likeCount,
                onTap: onToggleLike,
                busy: busy,
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Icon(
                    Icons.article_outlined,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.commentCount} comments',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
