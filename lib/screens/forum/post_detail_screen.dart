import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import 'package:goalytics_mobile/services/forum_service.dart';
import 'package:goalytics_mobile/widgets/forum/forum_comment_box.dart';
import 'package:goalytics_mobile/widgets/forum/forum_comment_tile.dart';
import 'package:goalytics_mobile/widgets/forum/forum_post_header.dart';
import 'package:goalytics_mobile/widgets/forum/forum_time.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goalytics_mobile/widgets/left_drawer.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId, this.withSidebar = true, this.username = 'GoalyticsUser'});

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

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: 'http://127.0.0.1:8000');
    try {
      final post = await service.getPost(widget.postId);
      final comments = await service.getComments(widget.postId);
      setState(() {
        _post = post;
        _comments = comments;
      });
    } catch (_) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendComment({int? parentId}) async {
    if (_commentCtrl.text.trim().isEmpty) return;
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: 'http://127.0.0.1:8000');
    await service.createComment(
      postId: widget.postId,
      content: _commentCtrl.text.trim(),
      parentId: parentId,
    );
    _commentCtrl.clear();
    _load();
  }

  Future<void> _toggleCommentLike(ForumComment c) async {
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: 'http://127.0.0.1:8000');
    final likeCount =
        await service.toggleCommentLike(postId: widget.postId, commentId: c.id);
    setState(() {
      _comments = _comments
          .map(
            (item) => _updateComment(item, c.id, likeCount, !c.isLiked),
          )
          .toList();
    });
  }

  void _handleReply(ForumComment comment) {
    _commentCtrl.text = '@${comment.user} ';
    FocusScope.of(context).requestFocus(FocusNode());
  }

  ForumComment _updateComment(
    ForumComment root,
    int id,
    int likeCount,
    bool liked,
  ) {
    if (root.id == id) {
      return root.copyWith(isLiked: liked, likeCount: likeCount);
    }
    return root.copyWith(
      replies:
          root.replies.map((r) => _updateComment(r, id, likeCount, liked)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : _post == null
            ? const Center(child: Text('Post not found'))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ForumPostHeader(post: _post!),
                      const SizedBox(height: 16),
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ForumCommentBox(
                        controller: _commentCtrl,
                        onSend: () => _sendComment(),
                      ),
                      const SizedBox(height: 12),
                      if (_comments.isEmpty)
                        const Text(
                          'No comments yet.',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        )
                      else
                        Column(
                          children: _comments
                              .map(
                                (c) => ForumCommentTile(
                                  comment: c,
                                  onLike: _toggleCommentLike,
                                  onReply: _handleReply,
                                  depth: 0,
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              );

    if (!widget.withSidebar) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: const Color(0xFF0F172A),
          title: const Text('Post Detail'),
        ),
        body: content,
      );
    }

    return SidebarScaffold(
      currentRoute: '/forum',
      username: widget.username,
      child: content,
    );
  }
}

extension on ForumComment {
  ForumComment copyWith({
    bool? isLiked,
    int? likeCount,
    List<ForumComment>? replies,
  }) {
    return ForumComment(
      id: id,
      user: user,
      content: content,
      createdAt: createdAt,
      parentId: parentId,
      replies: replies ?? this.replies,
      isOwner: isOwner,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      avatar: avatar,
    );
  }
}
