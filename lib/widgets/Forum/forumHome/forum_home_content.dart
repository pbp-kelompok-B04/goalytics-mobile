import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum_models.dart';
import 'package:goalytics_mobile/widgets/Forum/forumHome/forum_filters.dart';
import 'package:goalytics_mobile/widgets/Forum/forumHome/forum_home_header.dart';
import 'package:goalytics_mobile/widgets/Forum/forumHome/forum_list_card.dart';
import 'package:goalytics_mobile/widgets/Forum/forumHome/forum_states.dart';

typedef ForumPostCallback = void Function(ForumPost post);

class ForumHomeContent extends StatelessWidget {
  const ForumHomeContent({
    super.key,
    required this.posts,
    required this.loading,
    required this.notifUnread,
    required this.searchController,
    required this.league,
    required this.sort,
    required this.onSearchChanged,
    required this.onLeagueChanged,
    required this.onSortChanged,
    required this.onToggleMine,
    required this.onNewPost,
    required this.onNotifications,
    required this.onPostTap,
    required this.onPostLike,
    required this.onPostEdit,
    required this.onPostDelete,
    required this.myPostsActive,
  });

  final List<ForumPost> posts;
  final bool loading;
  final bool notifUnread;
  final TextEditingController searchController;
  final String league;
  final String sort;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onLeagueChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onToggleMine;
  final VoidCallback onNewPost;
  final VoidCallback onNotifications;
  final ForumPostCallback onPostTap;
  final ForumPostCallback onPostLike;
  final ForumPostCallback onPostEdit;
  final ForumPostCallback onPostDelete;
  final bool myPostsActive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ForumHomeHeader(
              onNotifications: onNotifications,
              onNewPost: onNewPost,
              showNotifDot: notifUnread,
              onToggleMyPosts: onToggleMine,
              myPostsActive: myPostsActive,
            ),
            const SizedBox(height: 20),
            ForumFilters(
              searchController: searchController,
              onSearchChanged: onSearchChanged,
              currentLeague: league,
              onLeagueChanged: onLeagueChanged,
              currentSort: sort,
              onSortChanged: onSortChanged,
            ),
            const SizedBox(height: 16),
            if (loading)
              const ForumLoadingCard()
            else if (posts.isEmpty)
              const ForumEmptyCard()
            else
              Column(
                children: posts
                    .map(
                      (p) => ForumListCard(
                        post: p,
                        onTap: () => onPostTap(p),
                        onLike: () => onPostLike(p),
                        onEdit: p.isAuthor ? () => onPostEdit(p) : null,
                        onDelete: p.isAuthor ? () => onPostDelete(p) : null,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
