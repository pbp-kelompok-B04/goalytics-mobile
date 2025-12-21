import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
  YoutubePlayerController? _controller;
  bool _isPlaying = false;

  void _startPlaying() {
    // On mobile (Android/iOS), open in YouTube app or browser for reliability
    // On web, use iframe player
    if (kIsWeb) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: widget.videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          mute: false,
          showFullscreenButton: true,
          loop: false,
          enableJavaScript: true,
          playsInline: true,
        ),
      );
      setState(() => _isPlaying = true);
    } else {
      // On mobile, open YouTube app or browser
      _openInYouTubeApp();
    }
  }

  Future<void> _openInYouTubeApp() async {
    // Try to open in YouTube app first
    final youtubeAppUri = Uri.parse('youtube://www.youtube.com/watch?v=${widget.videoId}');
    final youtubeWebUri = Uri.parse('https://www.youtube.com/watch?v=${widget.videoId}');
    
    try {
      // Try YouTube app first
      if (await canLaunchUrl(youtubeAppUri)) {
        await launchUrl(youtubeAppUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to browser
        await launchUrl(youtubeWebUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // If all else fails, try browser
      await launchUrl(youtubeWebUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumb = 'https://img.youtube.com/vi/${widget.videoId}/hqdefault.jpg';
    
    // On web and playing, show the iframe player
    if (kIsWeb && _isPlaying && _controller != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: YoutubePlayer(
          controller: _controller!,
          aspectRatio: 16 / 9,
        ),
      );
    }

    // Show thumbnail with play button
    return GestureDetector(
      onTap: _startPlaying,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                thumb,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(Icons.play_circle_fill,
                        color: Colors.white, size: 64),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            // YouTube logo indicator
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.white, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      kIsWeb ? 'YouTube' : 'Buka YouTube',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
