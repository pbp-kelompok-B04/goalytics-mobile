import 'package:flutter/material.dart';
import 'package:goalytics_mobile/config.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import 'package:goalytics_mobile/screens/forum/post_detail_screen.dart';
import 'package:goalytics_mobile/services/forum_service.dart';
import 'package:goalytics_mobile/widgets/forum/forum_card.dart';
import 'package:goalytics_mobile/widgets/forum/forum_chip_button.dart';
import 'package:goalytics_mobile/widgets/forum/forum_filter_chip.dart';
import 'package:goalytics_mobile/widgets/forum/forum_form_fields.dart';
import 'package:goalytics_mobile/widgets/forum/forum_post_card.dart';
import 'package:goalytics_mobile/widgets/forum/forum_time.dart';
import 'package:goalytics_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: kApiBaseUrl);

    // Debug: cek status login
    debugPrint('[ForumHomeScreen] loggedIn: ${req.loggedIn}');
    debugPrint('[ForumHomeScreen] cookies: ${req.cookies}');

    try {
      debugPrint('[ForumHomeScreen] fetching posts...');
      final posts = await service.fetchPosts(
        league: _league.isEmpty ? null : _league,
        sort: _sort,
        mine: _mine,
      );
      debugPrint('[ForumHomeScreen] posts fetched: ${posts.length}');

      debugPrint('[ForumHomeScreen] fetching notifications...');
      List<ForumNotification> notifs = [];
      // Hanya fetch notifikasi kalau sudah login
      if (req.loggedIn) {
        try {
          notifs = await service.getNotifications();
          debugPrint('[ForumHomeScreen] notifications fetched: ${notifs.length}');
        } catch (e) {
          debugPrint('[ForumHomeScreen] notifications failed (skipping): $e');
        }
      } else {
        debugPrint('[ForumHomeScreen] skipping notifications (not logged in)');
      }

      setState(() => _posts = posts);
      setState(() {
        _notifications = notifs;
        _notifUnread = notifs.any((n) => !n.isRead);
      });
    } catch (e, st) {
      debugPrint('[ForumHomeScreen] ERROR in _load: $e');
      debugPrint('[ForumHomeScreen] StackTrace: $st');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _markNotificationsRead() async {
    final req = context.read<CookieRequest>();
    final service = ForumService(req, baseUrl: kApiBaseUrl);
    await service.markNotificationsRead();
    setState(() {
      _notifUnread = false;
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });
  }

  void _openNotifications() async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Notifications'),
          content: SizedBox(
            width: 400,
            child: _notifications.isEmpty
                ? const Text('No notifications yet.')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _notifications
                        .map(
                          (n) => ListTile(
                            dense: true,
                            leading: Icon(
                              n.isRead
                                  ? Icons.notifications_none
                                  : Icons.notifications,
                              color: n.isRead
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF0F172A),
                            ),
                            title: Text(
                              '${n.actor} ${n.verb}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: n.isRead
                                    ? const Color(0xFF475569)
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            subtitle: Text(
                              formatForumTime(n.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                await _markNotificationsRead();
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Mark all read'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createPost() async {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String league = _league.isEmpty ? 'EPL' : _league;
    String? mediaUrl;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create New Post',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ForumSelectField(
                  value: league,
                  onChanged: (val) => league = val,
                ),
                const SizedBox(height: 12),
                ForumTextField(
                  controller: titleCtrl,
                  label: 'Title',
                  hint: "What's on your mind?",
                  maxLines: 1,
                ),
                const SizedBox(height: 12),
                ForumTextField(
                  controller: contentCtrl,
                  label: 'Content',
                  hint: 'Share your thoughts...',
                  maxLines: 5,
                ),
                const SizedBox(height: 12),
                ForumTextField(
                  controller: TextEditingController(text: mediaUrl),
                  label: 'Media URL (optional)',
                  hint: 'Paste image or video link',
                  onChanged: (v) => mediaUrl = v,
                  maxLines: 1,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty ||
                          contentCtrl.text.trim().isEmpty) {
                        return;
                      }
                      final req = context.read<CookieRequest>();
                      final service = ForumService(req, baseUrl: kApiBaseUrl);
                      await service.createPost(
                        title: titleCtrl.text.trim(),
                        content: contentCtrl.text.trim(),
                        league: league,
                        mediaUrl: mediaUrl,
                      );
                      if (!mounted) return;
                      Navigator.of(ctx).pop();
                      _load();
                    },
                    child: const Text(
                      'Publish Post',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 8),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: _openNotifications,
                      color: const Color(0xFF0F172A),
                    ),
                    if (_notifUnread)
                      const Positioned(
                        right: 8,
                        top: 8,
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: Color(0xFFEF4444),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Football Discussion Forum',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ForumChipButton(
                  label: 'My Posts',
                  icon: Icons.comment_outlined,
                  active: _mine,
                  onTap: () {
                    setState(() => _mine = !_mine);
                    _load();
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 10,
                  ),
                  onPressed: _createPost,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'New Post',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Join the conversation about your favorite teams and players.',
              style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            ForumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search, size: 18),
                            hintText: 'Search discussions',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF94A3B8),
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Leagues',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ForumFilterChip(
                        label: 'All',
                        active: _league.isEmpty,
                        onTap: () {
                          setState(() => _league = '');
                          _load();
                        },
                      ),
                      ...const [
                        ['EPL', 'Premier League'],
                        ['LALIGA', 'La Liga'],
                        ['SERIEA', 'Serie A'],
                        ['BUNDES', 'Bundesliga'],
                        ['LIGUE1', 'Ligue 1'],
                      ].map(
                        (e) => ForumFilterChip(
                          label: e[1],
                          active: _league == e[0],
                          onTap: () {
                            setState(() => _league = e[0]);
                            _load();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ForumFilterChip(
                        label: 'Newest',
                        active: _sort == 'newest',
                        onTap: () {
                          setState(() => _sort = 'newest');
                          _load();
                        },
                      ),
                      ForumFilterChip(
                        label: 'Oldest',
                        active: _sort == 'oldest',
                        onTap: () {
                          setState(() => _sort = 'oldest');
                          _load();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const ForumLoadingCard()
            else if (_filtered.isEmpty)
              const ForumEmptyCard()
            else
              Column(
                children: _filtered
                    .map(
                      (p) => ForumPostCard(
                        post: p,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(postId: p.id),
                            ),
                          );
                        },
                        onLike: () async {
                          final req = context.read<CookieRequest>();
                          final service = ForumService(
                            req,
                            baseUrl: kApiBaseUrl,
                          );
                          final likeCount = await service.togglePostLike(p.id);
                          setState(() {
                            _posts = _posts
                                .map(
                                  (e) => e.id == p.id
                                      ? e.copyWith(
                                          isLiked: !e.isLiked,
                                          likeCount: likeCount,
                                        )
                                      : e,
                                )
                                .toList();
                          });
                        },
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
        body: SafeArea(child: content),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const LeftDrawer(),
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
