import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';

void showForumNotificationDialog({
  required BuildContext context,
  required List<ForumNotification> notifications,
  required VoidCallback onMarkRead,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Notifications'),
      content: notifications.isEmpty
          ? const Text('No notifications yet.')
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: notifications.map((n) => ListTile(
                    title: Text('${n.actor} ${n.verb}'),
                    subtitle: Text(n.createdAt.toString()),
                  )).toList(),
            ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        TextButton(onPressed: () { onMarkRead(); Navigator.pop(ctx); }, child: const Text('Mark all read')),
      ],
    ),
  );
}
