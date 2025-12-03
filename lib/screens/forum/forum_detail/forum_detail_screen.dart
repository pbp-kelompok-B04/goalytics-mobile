import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import 'package:goalytics_mobile/services/forum_service.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goalytics_mobile/widgets/left_drawer.dart';

import 'forum_detail_header.dart';
import 'forum_detail_comment_input.dart';
import 'forum_detail_comment_list.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({
    super.key,
    required this.postId,
    this.withSidebar = true,
    this.username = 'GoalyticsUser',
  });

  final int postId;
  final bool withSidebar;
  final String username;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  ForumPost? _post;
  List<ForumComment> _comments = [];
  bool _loading = true;
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = ForumService(context.read(), baseUrl: 'http://127.0.0.1:8000');
    setState(() => _loading = true);

    try {
      final post = await service.getPost(widget.postId);
      final comments = await service.getComments(widget.postId);

      setState(() {
        _post = post;
        _comments = comments;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;

    final service = ForumService(context.read(), baseUrl: 'http://127.0.0.1:8000');
    await service.createComment(
      postId: widget.postId,
      content: _commentCtrl.text.trim(),
    );

    _commentCtrl.clear();
    _load();
  }

  Future<void> _toggleLike(ForumComment c) async {
    final service = ForumService(context.read(), baseUrl: 'http://127.0.0.1:8000');
    final count =
        await service.toggleCommentLike(postId: widget.postId, commentId: c.id);

    setState(() {
      _comments = _comments.map((e) => e.id == c.id
          ? e.copyWith(isLiked: !e.isLiked, likeCount: count)
          : e).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : _post == null
            ? const Center(child: Text('Post not found'))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ForumDetailHeader(post: _post!),
                      const SizedBox(height: 16),
                      ForumCommentInput(
                        controller: _commentCtrl,
                        onSend: _sendComment,
                      ),
                      const SizedBox(height: 12),
                      ForumDetailCommentList(
                        comments: _comments,
                        onLike: _toggleLike,
                      )
                    ],
                  ),
                ),
              );

    return widget.withSidebar
        ? LeftDrawer()
        : Scaffold(
            appBar: AppBar(title: const Text('Post Detail')),
            body: content,
          );
  }
}
