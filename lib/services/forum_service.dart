import 'package:goalytics_mobile/models/forum/forum_models.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ForumService {
  ForumService(this.request, {required this.baseUrl});

  final CookieRequest request;
  final String baseUrl;

  Future<List<ForumPost>> fetchPosts({
    String? league,
    String sort = 'newest',
    bool mine = false,
  }) async {
    final params = <String, String>{'sort': sort};
    if (league?.isNotEmpty == true) params['league'] = league!;
    if (mine) params['mine'] = 'true';
    final uri =
        Uri.parse('$baseUrl/forum/api/posts/').replace(queryParameters: params);
    final resp = await request.get(uri.toString());
    final list = (resp['data'] as List<dynamic>? ?? []);
    return list.map((e) => ForumPost.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ForumPost> getPost(int id) async {
    final resp = await request.get('$baseUrl/forum/api/posts/$id/');
    return ForumPost.fromJson(resp['data']);
  }

  Future<List<ForumComment>> getComments(int postId) async {
    final resp = await request.get('$baseUrl/forum/api/posts/$postId/comments/');
    final list = (resp['data'] as List<dynamic>? ?? []);
    return list.map((e) => ForumComment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ForumPost> createPost({
    required String title,
    required String content,
    String league = 'EPL',
    String? mediaUrl,
  }) async {
    final resp = await request.post(
      '$baseUrl/forum/api/posts/create/',
      {
        'title': title,
        'content': content,
        'league': league,
        if (mediaUrl != null) 'media_url': mediaUrl,
      },
    );
    return ForumPost.fromJson(resp['data']);
  }

  Future<void> updatePost({
    required int postId,
    String? title,
    String? content,
    String? league,
  }) async {
    await request.post(
      '$baseUrl/forum/api/posts/$postId/update/',
      {
        'post_id': postId.toString(),
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (league != null) 'league': league,
      },
    );
  }

  Future<void> deletePost(int postId) async {
    await request.post(
      '$baseUrl/forum/api/posts/$postId/delete/',
      {
        'post_id': postId.toString(),
      },
    );
  }

  Future<ForumComment> createComment({
    required int postId,
    required String content,
    int? parentId,
  }) async {
    final resp = await request.post(
      '$baseUrl/forum/api/posts/$postId/comments/create/',
      {
        'content': content,
        if (parentId != null) 'parent_id': parentId.toString(),
      },
    );
    return ForumComment.fromJson(resp['data']);
  }

  Future<void> updateComment({
    required int postId,
    required int commentId,
    required String content,
  }) async {
    await request.post(
      '$baseUrl/forum/api/comments/$commentId/update/',
      {
        'post_id': postId.toString(),
        'comment_id': commentId.toString(),
        'content': content,
      },
    );
  }

  Future<void> deleteComment({
    required int postId,
    required int commentId,
  }) async {
    await request.post(
      '$baseUrl/forum/api/comments/$commentId/delete/',
      {
        'post_id': postId.toString(),
        'comment_id': commentId.toString(),
      },
    );
  }

  Future<int> togglePostLike(int postId) async {
    final resp = await request.post(
      '$baseUrl/forum/api/posts/$postId/likes/',
      {'post_id': postId.toString()},
    );
    return resp['like_count'] ?? 0;
  }

  Future<int> toggleCommentLike({
    required int postId,
    required int commentId,
  }) async {
    final resp = await request.post(
      '$baseUrl/forum/api/comments/$commentId/likes/',
      {
        'post_id': postId.toString(),
        'comment_id': commentId.toString(),
      },
    );
    return resp['like_count'] ?? 0;
  }

  Future<List<ForumNotification>> getNotifications() async {
    final resp = await request.get('$baseUrl/forum/api/notifications/');
    final list = (resp['data'] as List<dynamic>? ?? []);
    return list
        .map((e) => ForumNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationsRead() async {
    await request.post('$baseUrl/forum/api/notifications/mark_read/', {});
  }
}
