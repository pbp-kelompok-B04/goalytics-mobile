import 'package:flutter/material.dart';
import '../../../widgets/forum/forum_detail/forum_detail_card.dart';

class ForumCommentInput extends StatelessWidget {
  const ForumCommentInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return ForumDetailCard(
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration:
                const InputDecoration(hintText: 'Write a comment...'),
          ),
        ),
        IconButton(onPressed: onSend, icon: const Icon(Icons.send))
      ]),
    );
  }
}
