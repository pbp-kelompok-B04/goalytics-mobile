import 'package:flutter/material.dart';
import '../../widgets/forum/forum_chip_button.dart';

class ForumHeader extends StatelessWidget {
  const ForumHeader({
    super.key,
    required this.notifUnread,
    required this.mine,
    required this.onBack,
    required this.onToggleMine,
    required this.onCreatePost,
    required this.onOpenNotifications,
  });

  final bool notifUnread;
  final bool mine;
  final VoidCallback onBack;
  final VoidCallback onToggleMine;
  final VoidCallback onCreatePost;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        Stack(
          children: [
            IconButton(icon: const Icon(Icons.notifications), onPressed: onOpenNotifications),
            if (notifUnread)
              const Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
              ),
          ],
        ),
        const Expanded(
          child: Text(
            'Football Discussion Forum',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        ForumChipButton(label: 'My Posts', icon: Icons.comment, active: mine, onTap: onToggleMine),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: onCreatePost,
          icon: const Icon(Icons.add),
          label: const Text('New Post'),
        )
      ],
    );
  }
}
