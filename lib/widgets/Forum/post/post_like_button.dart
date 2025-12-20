import 'package:flutter/material.dart';

class PostLikeButton extends StatelessWidget {
  const PostLikeButton({
    super.key,
    required this.isLiked,
    required this.count,
    required this.onTap,
    this.busy = false,
  });

  final bool isLiked;
  final int count;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: busy ? null : onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor:
            isLiked ? const Color(0xFFE11D48) : const Color(0xFF475569),
        side: BorderSide(
          color: isLiked ? const Color(0xFFFFE4E6) : const Color(0xFFE2E8F0),
        ),
        backgroundColor:
            isLiked ? const Color(0xFFFFF1F2) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      icon: busy
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFE11D48),
              ),
            )
          : Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: isLiked ? const Color(0xFFE11D48) : const Color(0xFF94A3B8),
            ),
      label: Text(
        '$count',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isLiked ? const Color(0xFFE11D48) : const Color(0xFF475569),
        ),
      ),
    );
  }
}
