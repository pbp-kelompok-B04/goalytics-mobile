import 'package:flutter/material.dart';
import 'package:goalytics_mobile/service/api_config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../models/ProfileEntry.dart';
import 'profile_detail_page.dart';
import 'package:goalytics_mobile/widgets/bottom_nav.dart';

const Color _navy = Color(0xFF0F172A);
const Color _navy2 = Color(0xFF111827);
const Color _cardShadow = Color(0x14000000);

String proxiedImageUrl(String originalUrl) {
  final raw = originalUrl.trim();
  if (raw.isEmpty) return "";

  if (raw.contains("/users/image-proxy/")) return raw;

  final base = ApiConfig.baseUrl.endsWith('/')
      ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
      : ApiConfig.baseUrl;

  final uri = Uri.tryParse(raw);
  if (uri == null) return "";

  final absolute =
      uri.hasScheme ? raw : (raw.startsWith('/') ? "$base$raw" : "$base/$raw");

  if (absolute.startsWith(base)) return absolute;

  return "$base/users/image-proxy/?url=${Uri.encodeComponent(absolute)}";
}

Widget profileAvatar({
  required String imageUrl,
  required String fallbackText,
  double radius = 26,
}) {
  final url = proxiedImageUrl(imageUrl);
  if (url.isEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF0EA5E9),
      child: Text(
        fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : "?",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  final size = radius * 2;
  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.white,
    child: ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : "?",
              style: const TextStyle(color: Colors.black),
            ),
          );
        },
      ),
    ),
  );
}

String prettyRole(String roleRaw) {
  final r = roleRaw.trim();
  if (r.isEmpty) return "User";
  return r[0].toUpperCase() + r.substring(1);
}

bool isVerifiedRole(String roleRaw) {
  final r = roleRaw.trim().toLowerCase();
  return r == "admin" || r == "analyst";
}


class ExploreProfilesPage extends StatefulWidget {
  const ExploreProfilesPage({super.key});

  @override
  State<ExploreProfilesPage> createState() => _ExploreProfilesPageState();
}

class _ExploreProfilesPageState extends State<ExploreProfilesPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  bool _initialized = false;
  List<ProfileEntry> _results = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDefault(CookieRequest request) async {
    setState(() => _loading = true);

    try {
      final response =
          await request.get("${ApiConfig.baseUrl}/users/api/users/?limit=50");

      if (!mounted) return;

      if (response is Map &&
          (response['status'] == true && response['results'] != null)) {
        final List<dynamic> items = response['results'] ?? [];
        setState(() {
          _results = items.map((item) => ProfileEntry.fromJson(item)).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (response is Map ? response['message'] : null) ??
                  "Failed to load users.",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error while loading users: $e")),
      );
    }
  }

  Future<void> _search(CookieRequest request) async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return _fetchDefault(request);
    }

    setState(() => _loading = true);

    try {
      final url =
          "${ApiConfig.baseUrl}/users/search.json?q=${Uri.encodeComponent(query)}";
      final response = await request.get(url);

      if (!mounted) return;

      if (response is Map &&
          (response['status'] == true && response['results'] != null)) {
        final List<dynamic> items = response['results'] ?? [];
        setState(() {
          _results = items.map((item) => ProfileEntry.fromJson(item)).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (response is Map ? response['message'] : null) ?? "Search failed.",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error while searching: $e")),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final request = context.read<CookieRequest>();
      _initialized = true;
      _fetchDefault(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      bottomNavigationBar: const BottomNav(),

      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER GELAP (mirip gambar) =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: _navy,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Search Users",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.white54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (_) => _search(request),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Search by username, name, or team...",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.send, color: Colors.white70),
                          onPressed: () => _search(request),
                          tooltip: "Search",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_loading) const LinearProgressIndicator(minHeight: 2),

            Expanded(
              child: _results.isEmpty && !_loading
                  ? const Center(child: Text("No users found."))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final p = _results[index];
                        return _UserCard(
                          profile: p,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProfileDetailPage(username: p.username),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final ProfileEntry profile;
  final VoidCallback onTap;

  const _UserCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final displayName = (profile.name.trim().isEmpty)
        ? profile.username
        : profile.name.trim();

    final roleText = prettyRole(profile.role);
    final verified = isVerifiedRole(profile.role);
    final favTeam = profile.favoriteTeam.trim().isEmpty
        ? "-"
        : profile.favoriteTeam.trim();

    final String? followersText = null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: _cardShadow,
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileAvatar(
                  imageUrl: profile.profilePicture,
                  fallbackText: profile.username,
                  radius: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _navy2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (verified) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 14, color: Colors.white),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "@${profile.username}",
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.group_outlined,
                              size: 18, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Text(
                            followersText ?? "",
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (followersText == null) const SizedBox(width: 0),
                          const SizedBox(width: 12),
                          const Icon(Icons.favorite_border,
                              size: 18, color: Color(0xFFFB7185)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              favTeam,
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            roleText,
                            style: const TextStyle(
                              color: Color(0xFF7C3AED),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
