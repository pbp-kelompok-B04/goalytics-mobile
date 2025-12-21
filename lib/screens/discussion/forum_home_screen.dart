import 'package:flutter/material.dart';
import 'package:goalytics_mobile/service/api_config.dart';
import 'package:goalytics_mobile/models/forum_models.dart';
import 'package:goalytics_mobile/screens/discussion/post_detail_screen.dart';
import 'package:goalytics_mobile/service/forum_service.dart';
import 'package:goalytics_mobile/widgets/Forum/forumHome/forum_editor_sheet.dart';
import 'package:goalytics_mobile/widgets/Forum/forumHome/forum_home_content.dart';
import 'package:goalytics_mobile/widgets/Forum/forumHome/forum_notification_sheet.dart';
import 'package:goalytics_mobile/widgets/left_drawer.dart';
import 'package:goalytics_mobile/widgets/bottom_nav.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goalytics_mobile/widgets/Forum/post/post_delete_sheet.dart';

class ForumHomeScreen extends StatefulWidget {
  const ForumHomeScreen({
    super.key,
    this.withSidebar = true,
    this.username = 'GoalyticsUser',
  });

  final bool withSidebar;
  final String username;

  @override
  State<ForumHomeScreen> createState() => _ForumHomeScreenState();
}

class _ForumHomeScreenState extends State<ForumHomeScreen> {
  List<ForumPost> _posts = [];
  bool _loading = true;
  String _league = '';
  String _sort = 'newest';
  bool _mine = false;
  String _query = '';
  List<ForumNotification> _notifications = [];
  bool _notifUnread = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: ApiConfig.baseUrl);
    try {
      final posts = await service.fetchPosts(
        league: _league.isEmpty ? null : _league,
        sort: _sort,
        mine: _mine,
      );
      final notifs = await service.getNotifications();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _notifications = notifs;
        _notifUnread = notifs.any((n) => !n.isRead);
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markNotificationsRead() async {
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: ApiConfig.baseUrl);
    await service.markNotificationsRead();
    setState(() {
      _notifUnread = false;
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });
  }

  Future<void> _openNotifications() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: ForumNotificationSheet(
            notifications: _notifications,
            onMarkRead: () async {
              await _markNotificationsRead();
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
          ),
        );
      },
    );
  }

  Future<void> _createPost() async {
    final result = await showModalBottomSheet<ForumEditorResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const ForumEditorSheet(),
      ),
    );

    if (result == null) return;
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: ApiConfig.baseUrl);
    await service.createPost(
      title: result.title,
      content: result.content,
      league: result.league,
      mediaUrl: result.mediaUrl,
    );
    if (!mounted) return;
    _showToast('Post created!');
    _load();
  }

  List<ForumPost> get _filtered {
    if (_query.isEmpty) return _posts;
    final q = _query.toLowerCase();
    return _posts
        .where(
          (p) =>
              p.title.toLowerCase().contains(q) ||
              p.content.toLowerCase().contains(q) ||
              p.author.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _editPost(ForumPost post) async {
    final result = await showModalBottomSheet<ForumEditorResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ForumEditorSheet(
          initialTitle: post.title,
          initialContent: post.content,
          initialLeague: post.league,
          initialMediaUrl: post.mediaUrl,
          initialAttachmentUrl: post.attachmentUrl,
        ),
      ),
    );
    if (result == null) return;
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: ApiConfig.baseUrl);
    await service.updatePost(
      postId: post.id,
      title: result.title,
      content: result.content,
      league: result.league,
    );
    if (!mounted) return;
    _showToast('Post updated!');
    _load();
  }

  Future<void> _deletePost(ForumPost post) async {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent, 
      builder: (ctx) {
        return GenericDeleteSheet(
          title: 'Delete Post',
          description:
              'Are you sure you want to delete this post? This action cannot be undone.',
          confirmLabel: 'Delete', 
          onConfirm: () async {
            Navigator.of(ctx).pop();
            try {
              final req = context.read<CookieRequest>();
              final service = ForumService(req, baseUrl: ApiConfig.baseUrl);

              await service.deletePost(post.id);

              if (!mounted) return;
              _showToast('Post deleted.');
              _load(); 
            } catch (e) {
              if (!mounted) return;
              _showToast('Failed to delete post.', isError: true);
            }
          },
        );
      },
    );
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF0F172A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ForumHomeContent(
          posts: _filtered,
          loading: _loading,
          notifUnread: _notifUnread,
          searchController: _searchCtrl,
          league: _league,
          sort: _sort,
          onSearchChanged: (v) => setState(() => _query = v),
          onLeagueChanged: (val) {
            setState(() => _league = val);
            _load();
          },
          onSortChanged: (val) {
            setState(() => _sort = val);
            _load();
          },
          onToggleMine: () {
            setState(() => _mine = !_mine);
            _load();
          },
          myPostsActive: _mine,
          onNewPost: _createPost,
          onNotifications: _openNotifications,
          onPostTap: (p) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PostDetailScreen(postId: p.id)),
            );
          },
          onPostLike: (p) async {
            final req = context.read<CookieRequest>();
            final service = ForumService(req, baseUrl: ApiConfig.baseUrl);
            final likeCount = await service.togglePostLike(p.id);
            setState(() {
              _posts = _posts
                  .map(
                    (e) => e.id == p.id
                        ? e.copyWith(isLiked: !e.isLiked, likeCount: likeCount)
                        : e,
                  )
                  .toList();
            });
          },
          onPostEdit: (p) => _editPost(p),
          onPostDelete: (p) => _deletePost(p),
        ),
      ),
    );

    if (!widget.withSidebar) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(child: content),
        bottomNavigationBar: const BottomNav(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: Colors.black,
      ),
      drawer: const LeftDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(child: content),
    );
  }
}

extension on ForumPost {
  ForumPost copyWith({bool? isLiked, int? likeCount}) {
    return ForumPost(
      id: id,
      author: author,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      league: league,
      avatar: avatar,
      commentCount: commentCount,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      isAuthor: isAuthor,
      mediaUrl: mediaUrl,
      attachmentUrl: attachmentUrl,
    );
  }
}
