import 'package:flutter/material.dart';
import 'package:goalytics_mobile/config.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import 'package:goalytics_mobile/screens/forum/post_detail_screen.dart';
import 'package:goalytics_mobile/services/forum_service.dart';
import 'package:goalytics_mobile/widgets/sidebar_scaffold.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'forum_header.dart';
import 'forum_filter_section.dart';
import 'forum_post_list.dart';
import 'forum_notifications.dart';
import 'forum_create_post.dart';

class ForumHomeScreen extends StatefulWidget {
  const ForumHomeScreen({super.key, this.withSidebar = true, this.username = 'GoalyticsUser'});
  final bool withSidebar;
  final String username;  

  @override
  State<ForumHomeScreen> createState() => _ForumHomeScreenState();
}

class _ForumHomeScreenState extends State<ForumHomeScreen> {
  List<ForumPost> _posts = [];
  List<ForumNotification> _notifications = [];
  bool _loading = true;
  bool _notifUnread = false;

  String _league = '';
  String _sort = 'newest';
  bool _mine = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final service = ForumService(context.read(), baseUrl: 'http://127.0.0.1:8000');

    try {
      final posts = await service.fetchPosts(
        league: _league.isEmpty ? null : _league,
        sort: _sort,
        mine: _mine,
      );
      final notifs = await service.getNotifications();

      setState(() {
        _posts = posts;
        _notifications = notifs;
        _notifUnread = notifs.any((n) => !n.isRead);
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openNotifications() => showForumNotificationDialog(
        context: context,
        notifications: _notifications,
        onMarkRead: () async {
          final service = ForumService(context.read(), baseUrl: 'http://127.0.0.1:8000');
          await service.markNotificationsRead();
          setState(() {
            _notifUnread = false;
            _notifications = _notifications.map((e) => e.copyWith(isRead: true)).toList();
          });
        },
      );

  void _createPost() => showCreatePostModal(
        context: context,
        initialLeague: _league,
        onSubmit: (title, content, league, mediaUrl) async {
          final service = ForumService(context.read(), baseUrl: 'http://127.0.0.1:8000');
          await service.createPost(
            title: title,
            content: content,
            league: league,
            mediaUrl: mediaUrl,
          );
          _load();
        },
      );

  List<ForumPost> get _filtered {
    if (_query.isEmpty) return _posts;
    final q = _query.toLowerCase();
    return _posts.where((p) =>
      p.title.toLowerCase().contains(q) ||
      p.content.toLowerCase().contains(q) ||
      p.author.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ForumHeader(
              notifUnread: _notifUnread,
              mine: _mine,
              onBack: () => Navigator.maybePop(context),
              onToggleMine: () { setState(() => _mine = !_mine); _load(); },
              onCreatePost: _createPost,
              onOpenNotifications: _openNotifications,
            ),
            const SizedBox(height: 12),
            ForumFilterSection(
              league: _league,
              sort: _sort,
              onLeagueChange: (v) { setState(() => _league = v); _load(); },
              onSortChange: (v) { setState(() => _sort = v); _load(); },
              onSearch: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 16),
            ForumPostList(
              loading: _loading,
              posts: _filtered,
              onTapPost: (p) => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PostDetailScreen(postId: p.id))
              ),
              onLike: (p) async {
                final service = ForumService(context.read(), baseUrl: 'http://127.0.0.1:8000');
                final count = await service.togglePostLike(p.id);
                setState(() {
                  _posts = _posts.map((e) => e.id == p.id
                      ? e.copyWith(isLiked: !e.isLiked, likeCount: count)
                      : e).toList();
                });
              },
            )
          ],
        ),
      ),
    );

    if (!widget.withSidebar) {
      return Scaffold(backgroundColor: const Color(0xFFF8FAFC), body: SafeArea(child: content));
    }

    return SidebarScaffold(
      currentRoute: '/forum',
      username: widget.username,
      child: SafeArea(child: content),
    );
  }
}
