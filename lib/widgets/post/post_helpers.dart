import 'package:flutter/material.dart';

String postLeagueLabel(String league) {
  switch (league) {
    case 'EPL':
      return 'Premier League';
    case 'LALIGA':
      return 'La Liga';
    case 'SERIEA':
      return 'Serie A';
    case 'BUNDES':
      return 'Bundesliga';
    case 'LIGUE1':
      return 'Ligue 1';
    default:
      return 'General';
  }
}

String postTimeAgo(DateTime date) {
  final seconds = DateTime.now().difference(date).inSeconds;
  const intervals = {
    'year': 31536000,
    'month': 2592000,
    'week': 604800,
    'day': 86400,
    'hour': 3600,
    'minute': 60,
  };
  for (final entry in intervals.entries) {
    final interval = seconds ~/ entry.value;
    if (interval >= 1) {
      return interval == 1
          ? '1 ${entry.key} ago'
          : '$interval ${entry.key}s ago';
    }
  }
  return 'just now';
}

Widget buildPostAvatar(String name, String? url, {double size = 48}) {
  final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
  return CircleAvatar(
    radius: size / 2,
    backgroundColor: const Color(0xFFE2E8F0),
    backgroundImage: url != null ? NetworkImage(url) : null,
    child: url == null
        ? Text(
            initials,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w700,
            ),
          )
        : null,
  );
}
