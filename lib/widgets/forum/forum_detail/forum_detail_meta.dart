import 'package:goalytics_mobile/models/forum/forum_models.dart';

extension ForumCommentCopy on ForumComment {
  ForumComment copyWith({
    bool? isLiked,
    int? likeCount,
  }) {
    return ForumComment(
      id: id,
      user: user,
      content: content,
      createdAt: createdAt,
      parentId: parentId,
      replies: replies,
      isOwner: isOwner,
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
      avatar: avatar,
    );
  }
}
