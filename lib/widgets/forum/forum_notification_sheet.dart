import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import 'package:goalytics_mobile/widgets/post/post_helpers.dart';

class ForumNotificationSheet extends StatelessWidget {
  const ForumNotificationSheet({
    super.key,
    required this.notifications,
    required this.onMarkRead,
  });

  final List<ForumNotification> notifications;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: onMarkRead,
                child: const Text('Mark all read'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No notifications yet.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      n.isRead
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                      color: n.isRead
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF0F172A),
                    ),
                    title: Text(
                      '${n.actor} ${n.verb}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: n.isRead
                            ? const Color(0xFF475569)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      postTimeAgo(n.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
