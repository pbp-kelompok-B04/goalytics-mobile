import 'package:flutter/material.dart';
import 'package:goalytics_mobile/config.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import 'package:goalytics_mobile/service/forum_service.dart';
import 'package:goalytics_mobile/widgets/post/post_action_sheet.dart';
import 'package:goalytics_mobile/widgets/post/post_back_button.dart';
import 'package:goalytics_mobile/widgets/post/post_card.dart';
import 'package:goalytics_mobile/widgets/post/post_discussion_section.dart';
import 'package:goalytics_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

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
  bool _sendingComment = false;
  bool _likingPost = false;
  final Set<int> _collapsedReplies = {};
  final _commentCtrl = TextEditingController();
  final _replyCtrl = TextEditingController();
  final _editCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _replyCtrl.dispose();
    _editCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _loadWithSpinner(showSpinner: true);
  }

  Future<void> _loadWithSpinner({bool showSpinner = false}) async {
    if (showSpinner && mounted) setState(() => _loading = true);
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: kApiBaseUrl);
    try {
      final post = await service.getPost(widget.postId);
      final comments = await service.getComments(widget.postId);
      if (!mounted) return;
      setState(() {
        _post = post;
        _comments = comments;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _post = null;
        _comments = [];
      });
      _showToast('Error loading post. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendComment({
    required String content,
    int? parentId,
    VoidCallback? onComplete,
  }) async {
    if (content.trim().isEmpty || _sendingComment) return;
    setState(() => _sendingComment = true);
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: kApiBaseUrl);
    try {
      await service.createComment(
        postId: widget.postId,
        content: content.trim(),
        parentId: parentId,
      );
      _commentCtrl.clear();
      _replyCtrl.clear();
      onComplete?.call();
      _showToast(parentId == null ? 'Comment posted!' : 'Reply added!');
      await _loadWithSpinner(showSpinner: false);
    } catch (_) {
      _showToast('Unable to send comment. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _sendingComment = false);
    }
  }

  Future<void> _togglePostLike() async {
    if (_post == null || _likingPost) return;
    setState(() => _likingPost = true);
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: kApiBaseUrl);
    try {
      final likeCount = await service.togglePostLike(_post!.id);
      if (!mounted) return;
      setState(() {
        _post = _post!.copyWith(
          isLiked: !_post!.isLiked,
          likeCount: likeCount,
        );
      });
    } catch (_) {
      _showToast('Unable to update like.', isError: true);
    } finally {
      if (mounted) setState(() => _likingPost = false);
    }
  }

  Future<void> _toggleCommentLike(ForumComment comment) async {
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: kApiBaseUrl);
    try {
      final likeCount = await service.toggleCommentLike(
        postId: widget.postId,
        commentId: comment.id,
      );
      _updateCommentInTree(
        comment.id,
        (c) => c.copyWith(isLiked: !c.isLiked, likeCount: likeCount),
      );
    } catch (_) {
      _showToast('Unable to update like.', isError: true);
    }
  }

  Future<void> _editComment(ForumComment comment, String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: kApiBaseUrl);
    try {
      await service.updateComment(
        postId: widget.postId,
        commentId: comment.id,
        content: trimmed,
      );
      Navigator.of(context).pop();
      _showToast('Comment updated!');
      await _loadWithSpinner(showSpinner: false);
    } catch (_) {
      _showToast('Unable to update comment.', isError: true);
    }
  }

  Future<void> _deleteComment(ForumComment comment) async {
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: kApiBaseUrl);
    try {
      await service.deleteComment(
        postId: widget.postId,
        commentId: comment.id,
      );
      Navigator.of(context).pop();
      _showToast('Comment deleted.');
      await _loadWithSpinner(showSpinner: false);
    } catch (_) {
      _showToast('Unable to delete comment.', isError: true);
    }
  }

  void _updateCommentInTree(
    int id,
    ForumComment Function(ForumComment current) transform,
  ) {
    ForumComment updateNode(ForumComment node) {
      if (node.id == id) return transform(node);
      return node.copyWith(
        replies: node.replies.map(updateNode).toList(),
      );
    }

    if (!mounted) return;
    setState(() {
      _comments = _comments.map(updateNode).toList();
    });
  }

  void _toggleReplies(int id) {
    setState(() {
      if (_collapsedReplies.contains(id)) {
        _collapsedReplies.remove(id);
      } else {
        _collapsedReplies.add(id);
      }
    });
  }

  Widget _buildLoadingLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PostBackButton(),
              const SizedBox(height: 16),
              _buildPlaceholderPanel(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Loading post...',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildPlaceholderPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Discussion',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 12),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Loading comments...',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ),
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

  Widget _buildErrorLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PostBackButton(),
              const SizedBox(height: 16),
              _buildPlaceholderPanel(
                child: const Center(
                  child: Text(
                    'Post not found',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PostDiscussionSection(
                commentController: _commentCtrl,
                onSendComment: () => _sendComment(content: _commentCtrl.text),
                sendingComment: _sendingComment,
                comments: _comments,
                commentCount: _comments.length,
                collapsedReplies: _collapsedReplies,
                onToggleReplies: _toggleReplies,
                onLikeComment: _toggleCommentLike,
                onReplyComment: _openReplySheet,
                onEditComment: _openEditSheet,
                onDeleteComment: _confirmDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PostBackButton(),
              const SizedBox(height: 16),
              PostCard(
                post: _post!,
                onToggleLike: _togglePostLike,
                busy: _likingPost,
              ),
              const SizedBox(height: 16),
              _buildDiscussion(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscussion() {
    return PostDiscussionSection(
      commentController: _commentCtrl,
      onSendComment: () => _sendComment(content: _commentCtrl.text),
      sendingComment: _sendingComment,
      comments: _comments,
      commentCount: _post?.commentCount ?? _comments.length,
      collapsedReplies: _collapsedReplies,
      onToggleReplies: _toggleReplies,
      onLikeComment: _toggleCommentLike,
      onReplyComment: _openReplySheet,
      onEditComment: _openEditSheet,
      onDeleteComment: _confirmDelete,
    );
  }

  Widget _buildPlaceholderPanel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
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
      child: child,
    );
  }

  void _openReplySheet(ForumComment comment) {
    _replyCtrl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return PostActionSheet(
          title: 'Reply to ${comment.user}',
          controller: _replyCtrl,
          primaryLabel: 'Reply',
          onSubmit: () => _sendComment(
            content: _replyCtrl.text,
            parentId: comment.id,
            onComplete: () => Navigator.of(ctx).pop(),
          ),
        );
      },
    );
  }

  void _openEditSheet(ForumComment comment) {
    _editCtrl.text = comment.content;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return PostActionSheet(
          title: 'Edit Comment',
          controller: _editCtrl,
          primaryLabel: 'Save Changes',
          onSubmit: () => _editComment(comment, _editCtrl.text),
        );
      },
    );
  }

  void _confirmDelete(ForumComment comment) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text(
            'Delete Comment',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Are you sure you want to delete this comment? This action cannot be undone.',
            style: TextStyle(color: Color(0xFF475569)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _deleteComment(comment),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = SafeArea(
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: _loading
            ? _buildLoadingLayout()
            : _post == null
                ? _buildErrorLayout()
                : _buildLoadedLayout(),
      ),
    );

    if (!widget.withSidebar) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: page,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
        backgroundColor: const Color(0xff1c2341),
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: page,
    );
  }
}

extension on ForumPost {
  ForumPost copyWith({
    bool? isLiked,
    int? likeCount,
    int? commentCount,
  }) {
    return ForumPost(
      id: id,
      author: author,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      league: league,
      avatar: avatar,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      isAuthor: isAuthor,
      mediaUrl: mediaUrl,
      attachmentUrl: attachmentUrl,
    );
  }
}

extension on ForumComment {
  ForumComment copyWith({
    bool? isLiked,
    int? likeCount,
    List<ForumComment>? replies,
    String? content,
  }) {
    return ForumComment(
      id: id,
      user: user,
      content: content ?? this.content,
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
