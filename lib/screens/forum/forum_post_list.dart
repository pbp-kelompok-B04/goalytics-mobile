import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import '../../widgets/forum/forum_post_card.dart';
import '../../widgets/forum/forum_loading_card.dart';
import '../../widgets/forum/forum_empty_card.dart';

class ForumPostList extends StatelessWidget {
  const ForumPostList({
    super.key,
    required this.loading,
    required this.posts,
    required this.onTapPost,
    required this.onLike,
  });

  final bool loading;
  final List<ForumPost> posts;
  final void Function(ForumPost post) onTapPost;
  final void Function(ForumPost post) onLike;

  @override
  Widget build(BuildContext context) {
    if (loading) return const ForumLoadingCard();
    if (posts.isEmpty) return const ForumEmptyCard();

    return Column(
      children: posts.map(
        (p) => ForumPostCard(
          post: p,
          onTap: () => onTapPost(p),
          onLike: () => onLike(p),
        ),
      ).toList(),
    );
  }
}
