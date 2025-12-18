import 'package:flutter/material.dart';

class PostMediaPreview extends StatelessWidget {
  const PostMediaPreview({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final lower = url.toLowerCase();
    final looksLikeImage =
        RegExp(r'\.(png|jpe?g|gif|webp|bmp|avif)$').hasMatch(lower);
    if (looksLikeImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => PostMediaFallback(url: url),
        ),
      );
    }
    return PostMediaFallback(url: url);
  }
}

class PostMediaFallback extends StatelessWidget {
  const PostMediaFallback({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Media preview',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            url,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
