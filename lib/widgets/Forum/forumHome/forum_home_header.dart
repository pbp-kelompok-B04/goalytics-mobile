import 'package:flutter/material.dart';

class ForumHomeHeader extends StatelessWidget {
  const ForumHomeHeader({
    super.key,
    required this.onNotifications,
    required this.onNewPost,
    required this.showNotifDot,
    required this.onToggleMyPosts,
    required this.myPostsActive,
    this.onManage,
    this.showManage = false,
  });

  final VoidCallback onNotifications;
  final VoidCallback onNewPost;
  final VoidCallback onToggleMyPosts;
  final bool showNotifDot;
  final bool myPostsActive;
  final VoidCallback? onManage;
  final bool showManage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Football Discussion Forum',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Join the conversation about your favorite teams and players.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (showManage && onManage != null)
                  OutlinedButton.icon(
                    onPressed: onManage,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.dashboard_customize_outlined, size: 18),
                    label: const Text(
                      'Manage Forum',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onNotifications,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF475569),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.notifications_outlined, size: 18),
                      label: const Text(
                        'Notifications',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (showNotifDot)
                      const Positioned(
                        top: 2,
                        right: 2,
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: Color(0xFFEF4444),
                        ),
                      ),
                  ],
                ),
                _PillButton(
                  active: myPostsActive,
                  onTap: onToggleMyPosts,
                  icon: Icons.forum_outlined,
                  label: myPostsActive ? 'Showing My Posts' : 'My Posts',
                ),
                ElevatedButton.icon(
                  onPressed: onNewPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 10,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'New Post',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.active,
    required this.onTap,
    required this.icon,
    required this.label,
  });

  final bool active;
  final VoidCallback onTap;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? const Color(0xFF0F172A) : Colors.white,
        foregroundColor: active ? Colors.white : const Color(0xFF475569),
        side: BorderSide(
          color: active ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
