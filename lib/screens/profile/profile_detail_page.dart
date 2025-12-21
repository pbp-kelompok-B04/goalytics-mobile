import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../service/api_config.dart';

const Color _navy = Color(0xFF0F172A);
const Color _navy2 = Color(0xFF111827);
const Color _muted = Color(0xFF6B7280);

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
  double radius = 44,
}) {
  final url = proxiedImageUrl(imageUrl);
  if (url.isEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF0EA5E9),
      child: Text(
        fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : "?",
        style: TextStyle(
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
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
              style: TextStyle(fontSize: radius * 0.75),
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

      if (response is Map && response['status'] == true) {
        setState(() {
          data = Map<String, dynamic>.from(response['data'] ?? {});
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
    final roleRaw = (data?["role"] ?? "").toString();
    final roleText = prettyRole(roleRaw);
    final verified = isVerifiedRole(roleRaw);

    final avatar = (data?["avatar"] ?? "").toString();
    final username = (data?["username"] ?? widget.username).toString();

    final bio = (data?["bio"] ?? "").toString().trim();
    final favTeam = (data?["favorite_team"] ?? "").toString();
    final favLeague = (data?["favorite_league"] ?? "").toString();
    final prefPos = (data?["preferred_position"] ?? "").toString();

    final ig = (data?["instagram_url"] ?? "").toString().trim();
    final x = (data?["x_url"] ?? "").toString().trim();
    final web = (data?["website_url"] ?? "").toString().trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : data == null
                ? const Center(child: Text("Failed to load profile"))
                : Stack(
                    children: [
                      Container(
                        height: 170,
                        width: double.infinity,
                        color: _navy,
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===== top bar =====
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "Profile",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // ===== hero card =====
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.fromLTRB(16, 20, 16, 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: profileAvatar(
                                      imageUrl: avatar,
                                      fallbackText: username,
                                      radius: 46,
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // username + verified
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "@$username",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: _navy2,
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
                                          child: const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // role pill
                                  Center(
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

                                  const SizedBox(height: 14),

                                  Text(
                                    bio.isEmpty ? "Belum ada bio" : bio,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF344054),
                                      height: 1.35,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ===== football prefs =====
                            _SectionCard(
                              title: "Preferensi Sepak Bola",
                              child: Column(
                                children: [
                                  _InfoRow(label: "Favorite club", value: favTeam),
                                  const SizedBox(height: 8),
                                  _InfoRow(label: "Favorite league", value: favLeague),
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                      label: "Preferred position", value: prefPos),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ===== socials =====
                            _SectionCard(
                              title: "Media Sosial",
                              child: Column(
                                children: [
                                  _InfoRow(label: "Instagram", value: ig),
                                  const SizedBox(height: 8),
                                  _InfoRow(label: "X", value: x),
                                  const SizedBox(height: 8),
                                  _InfoRow(label: "Website", value: web),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _navy2,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final v = value.trim().isEmpty ? "-" : value.trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: _navy2,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            v,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF344054),
            ),
          ),
        ),
      ],
    );
  }
}
