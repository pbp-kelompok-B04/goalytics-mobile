import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

String? _extractYouTubeId(String url) {
  final videoId = YoutubePlayerController.convertUrlToId(url);
  if (videoId != null) return videoId;
  try {
    final uri = Uri.parse(url);
    if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
    }
    if (uri.host.contains('youtube.com')) {
      if (uri.pathSegments.contains('shorts')) {
        final index = uri.pathSegments.indexOf('shorts');
        if (index + 1 < uri.pathSegments.length) {
          return uri.pathSegments[index + 1];
        }
      }
      if (uri.path == '/watch') {
        return uri.queryParameters['v'];
      }
      if (uri.pathSegments.contains('embed')) {
        final index = uri.pathSegments.indexOf('embed');
        if (index + 1 < uri.pathSegments.length) {
          return uri.pathSegments[index + 1];
        }
      }
    }
  } catch (_) {}
  final regExp = RegExp(
      r'(?:youtu\.be\/|youtube\.com\/(?:watch\?[^#]*v=|shorts\/|embed\/))([A-Za-z0-9_-]{6,})');
  final match = regExp.firstMatch(url);
  return match?.group(1);
}

class PostMediaPreview extends StatelessWidget {
  const PostMediaPreview({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final ytId = _extractYouTubeId(url);
    if (ytId != null) {
      return YouTubeVideoPlayer(videoId: ytId, url: url);
    }

    final lower = url.toLowerCase();
    final looksLikeImage =
        RegExp(r'\.(png|jpe?g|gif|webp|bmp|avif)$').hasMatch(lower) ||
            url.contains('images') ||
            url.contains('img') ||
            url.contains('media');

    if (looksLikeImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => PostMediaFallback(url: url),
        ),
      );
    }
    return PostMediaFallback(url: url);
  }
}

class YouTubeVideoPlayer extends StatefulWidget {
  const YouTubeVideoPlayer({
    super.key,
    required this.videoId,
    required this.url,
  });

  final String videoId;
  final String url;

  @override
  State<YouTubeVideoPlayer> createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: YoutubePlayer(
        controller: _controller,
        aspectRatio: 16 / 9,
      ),
    );
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
