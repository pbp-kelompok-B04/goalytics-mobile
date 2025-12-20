import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../service/api_config.dart';

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
  double radius = 50,
}) {
  final url = proxiedImageUrl(imageUrl);
  if (url.isEmpty) {
    return CircleAvatar(
      radius: radius,
      child: Text(
        fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : "?",
        style: TextStyle(fontSize: radius * 0.8),
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
              style: TextStyle(fontSize: radius * 0.8),
            ),
          );
        },
      ),
    ),
  );
}

class ProfileDetailPage extends StatefulWidget {
  final String username;

  const ProfileDetailPage({super.key, required this.username});

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  bool _loading = true;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.get(
        "${ApiConfig.baseUrl}/users/api/profile/${widget.username}/",
      );

      if (!mounted) return;

      if (response['status'] == true) {
        setState(() {
          data = response['data'];
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load profile")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : data == null
              ? const Center(child: Text("Failed to load profile"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      profileAvatar(
                        imageUrl: (data!["avatar"] ?? "").toString(),
                        fallbackText: widget.username,
                        radius: 50,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        data!["bio"]?.toString().isNotEmpty == true
                            ? data!["bio"]
                            : "(no bio provided)",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Divider(),
                      _infoTile("Favorite Team", data!["favorite_team"]),
                      _infoTile("Favorite League", data!["favorite_league"]),
                      _infoTile("Preferred Position", data!["preferred_position"]),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _infoTile(String title, dynamic value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        value?.toString().isNotEmpty == true ? value.toString() : "-",
      ),
    );
  }
}
