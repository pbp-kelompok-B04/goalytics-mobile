import 'package:flutter/material.dart';

class ForumDetailMeta extends StatelessWidget {
  const ForumDetailMeta({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: Colors.grey),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))
    ]);
  }
}
