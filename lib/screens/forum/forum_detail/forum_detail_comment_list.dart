import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import 'forum_detail_comment_card.dart';

class ForumDetailCommentList extends StatelessWidget {
  const ForumDetailCommentList({
    super.key,
    required this.comments,
    required this.onLike,
  });

  final List<ForumComment> comments;
  final void Function(ForumComment c) onLike;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Text('No comments yet.', style: TextStyle(color: Colors.grey));
    }

    return Column(
      children: comments
          .map((c) => ForumDetailCommentCard(
                comment: c,
                onLike: () => onLike(c),
              ))
          .toList(),
    );
  }
}
