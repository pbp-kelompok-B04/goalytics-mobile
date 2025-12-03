import 'package:meta/meta.dart';

@immutable
class ForumPost {
  const ForumPost({
    required this.id,
    required this.author,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.league,
    this.avatar,
    this.commentCount = 0,
    this.likeCount = 0,
    this.isLiked = false,
    this.isAuthor = false,
    this.mediaUrl,
    this.attachmentUrl,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'] as int,
      author: json['author'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ??
          DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.now(),
      league: json['league'] ?? 'EPL',
      avatar: json['avatar'],
      commentCount: json['comment_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isAuthor: json['is_author'] ?? false,
      mediaUrl: json['media_url'],
      attachmentUrl: json['attachment_url'],
    );
  }

  final int id;
  final String author;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String league;
  final String? avatar;
  final int commentCount;
  final int likeCount;
  final bool isLiked;
  final bool isAuthor;
  final String? mediaUrl;
  final String? attachmentUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'league': league,
      'comment_count': commentCount,
      'like_count': likeCount,
      'is_liked': isLiked,
      'is_author': isAuthor,
      if (avatar != null) 'avatar': avatar,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
    };
  }
}

@immutable
class ForumComment {
  const ForumComment({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
    this.parentId,
    this.replies = const [],
    this.isOwner = false,
    this.likeCount = 0,
    this.isLiked = false,
    this.avatar,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['id'] as int,
      user: json['user'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      parentId: json['parent_id'],
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((e) => ForumComment.fromJson(e as Map<String, dynamic>))
          .toList(),
      isOwner: json['is_owner'] ?? false,
      likeCount: json['like_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      avatar: json['avatar'],
    );
  }

  final int id;
  final String user;
  final String content;
  final DateTime createdAt;
  final int? parentId;
  final List<ForumComment> replies;
  final bool isOwner;
  final int likeCount;
  final bool isLiked;
  final String? avatar;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'parent_id': parentId,
      'is_owner': isOwner,
      'like_count': likeCount,
      'is_liked': isLiked,
      if (avatar != null) 'avatar': avatar,
      'replies': replies.map((c) => c.toJson()).toList(),
    };
  }
}

@immutable
class ForumNotification {
  const ForumNotification({
    required this.id,
    required this.actor,
    required this.verb,
    required this.createdAt,
    this.postId,
    this.commentId,
    this.isRead = false,
  });

  factory ForumNotification.fromJson(Map<String, dynamic> json) {
    return ForumNotification(
      id: json['id'] as int,
      actor: json['actor'] ?? '',
      verb: json['verb'] ?? '',
      postId: json['post_id'],
      commentId: json['comment_id'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  final int id;
  final String actor;
  final String verb;
  final int? postId;
  final int? commentId;
  final bool isRead;
  final DateTime createdAt;

  ForumNotification copyWith({
    bool? isRead,
  }) {
    return ForumNotification(
      id: id,
      actor: actor,
      verb: verb,
      postId: postId,
      commentId: commentId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actor': actor,
      'verb': verb,
      'post_id': postId,
      'comment_id': commentId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
