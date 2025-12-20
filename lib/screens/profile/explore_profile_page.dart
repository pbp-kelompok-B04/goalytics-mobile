import 'package:flutter/material.dart';
import 'package:goalytics_mobile/service/api_config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../models/ProfileEntry.dart';
import 'profile_detail_page.dart';

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
  double radius = 20,
}) {
  final url = proxiedImageUrl(imageUrl);
  if (url.isEmpty) {
    return CircleAvatar(
      radius: radius,
      child: Text(
        fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : "?",
      ),
    );
  }

  final size = radius * 2;
  return CircleAvatar(
    radius: radius,
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
            ),
          );
        },
      ),
    ),
  );
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
      appBar: AppBar(title: const Text("Explore Profiles")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _search(request),
              decoration: InputDecoration(
                hintText: "Search by username, name, bio...",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _search(request),
                ),
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: _results.isEmpty && !_loading
                ? const Center(child: Text("No users found."))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final p = _results[index];

                      return ListTile(
                        leading: profileAvatar(
                          imageUrl: p.profilePicture,
                          fallbackText: p.username,
                          radius: 20,
                        ),
                        title: Text(p.username),
                        subtitle: Text(
                          p.bio.isEmpty ? "(no bio yet)" : p.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
    );
  }
}
