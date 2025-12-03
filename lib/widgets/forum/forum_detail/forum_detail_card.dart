import 'package:flutter/material.dart';

class ForumDetailCard extends StatelessWidget {
  const ForumDetailCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(18)),
        boxShadow: [
          BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6))
        ],
      ),
      child: child,
    );
  }
}
