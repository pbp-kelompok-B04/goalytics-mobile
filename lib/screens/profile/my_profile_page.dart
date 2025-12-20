import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../models/ProfileEntry.dart';
import '../../service/api_config.dart';

String proxiedImageUrl(String originalUrl) {
  final raw = originalUrl.trim();
  if (raw.isEmpty) return "";

  // Avoid double-proxy.
  if (raw.contains("/users/image-proxy/")) return raw;

  final base = ApiConfig.baseUrl.endsWith('/')
      ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
      : ApiConfig.baseUrl;

  final uri = Uri.tryParse(raw);
  if (uri == null) return "";

  // If backend returns a relative path, turn it into an absolute URL.
  final absolute =
      uri.hasScheme ? raw : (raw.startsWith('/') ? "$base$raw" : "$base/$raw");

  // If already served from our backend domain, no need to proxy.
  if (absolute.startsWith(base)) return absolute;

  return "$base/users/image-proxy/?url=${Uri.encodeComponent(absolute)}";
}

Widget profileAvatar({
  required String imageUrl,
  required String fallbackText,
  double radius = 32,
}) {
  final url = proxiedImageUrl(imageUrl);
  if (url.isEmpty) {
    return CircleAvatar(
      radius: radius,
      child: Text(
        fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : "?",
        style: TextStyle(fontSize: radius * 0.75),
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
              style: TextStyle(fontSize: radius * 0.75),
            ),
          );
        },
      ),
    ),
  );
}

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  ProfileEntry? _profile;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _favoriteTeamController = TextEditingController();
  final TextEditingController _favoriteLeagueController = TextEditingController();
  final TextEditingController _preferredPositionController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _profilePictureController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      _loadProfile(request);
    });
  }

  Future<void> _loadProfile(CookieRequest request) async {
    try {
      final response = await request.get("${ApiConfig.baseUrl}/users/api/me/");

      if (response['status'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final profile = ProfileEntry.fromJson(data);

        setState(() {
          _profile = profile;

          _bioController.text = profile.bio;
          _favoriteTeamController.text = profile.favoriteTeam;
          _favoriteLeagueController.text = profile.favoriteLeague;
          _preferredPositionController.text = profile.preferredPosition;
          _instagramController.text = profile.instagramUrl;
          _xController.text = profile.xUrl;
          _websiteController.text = profile.websiteUrl;
          _profilePictureController.text = profile.profilePicture;

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat profil: $e")),
      );
    }
  }

  Future<void> _saveProfile(CookieRequest request) async {
    if (_profile == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    _profile!
      ..bio = _bioController.text.trim()
      ..favoriteTeam = _favoriteTeamController.text.trim()
      ..favoriteLeague = _favoriteLeagueController.text.trim()
      ..preferredPosition = _preferredPositionController.text.trim()
      ..instagramUrl = _instagramController.text.trim()
      ..xUrl = _xController.text.trim()
      ..websiteUrl = _websiteController.text.trim()
      ..profilePicture = _profilePictureController.text.trim();

    try {
      final body = jsonEncode(_profile!.toUpdateJson());

      final response = await request.postJson(
        "${ApiConfig.baseUrl}/users/api/me/",
        body,
      );

      if (!mounted) return;

      if (response['status'] == true) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui")),
        );
      } else {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan profil: $response")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _favoriteTeamController.dispose();
    _favoriteLeagueController.dispose();
    _preferredPositionController.dispose();
    _instagramController.dispose();
    _xController.dispose();
    _websiteController.dispose();
    _profilePictureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          if (!_isLoading && _profile != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text("Gagal memuat profil."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            profileAvatar(
                              imageUrl: _profile!.profilePicture,
                              fallbackText: _profile!.username,
                              radius: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _profile!.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "@${_profile!.username}",
                                    style:
                                        const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _profile!.email,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Text(
                          "Bio",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _isEditing
                            ? TextFormField(
                                controller: _bioController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Tulis bio kamu...",
                                ),
                              )
                            : Text(_profile!.bio.isEmpty
                                ? "Belum ada bio"
                                : _profile!.bio),
                        const SizedBox(height: 24),

                        Text(
                          "Preferensi Sepak Bola",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        _buildEditableRow(
                          label: "Tim favorit",
                          isEditing: _isEditing,
                          controller: _favoriteTeamController,
                          displayValue: _profile!.favoriteTeam,
                          hintText: "Contoh: FC Barcelona",
                        ),
                        const SizedBox(height: 8),

                        _buildEditableRow(
                          label: "Liga favorit",
                          isEditing: _isEditing,
                          controller: _favoriteLeagueController,
                          displayValue: _profile!.favoriteLeague,
                          hintText: "Contoh: La Liga, Premier League",
                        ),
                        const SizedBox(height: 8),

                        _buildEditableRow(
                          label: "Posisi favorit",
                          isEditing: _isEditing,
                          controller: _preferredPositionController,
                          displayValue: _profile!.preferredPosition,
                          hintText: "Contoh: Striker, Winger",
                        ),

                        const SizedBox(height: 24),

                        Text(
                          "Media Sosial",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        _buildEditableRow(
                          label: "Instagram",
                          isEditing: _isEditing,
                          controller: _instagramController,
                          displayValue: _profile!.instagramUrl,
                          hintText: "https://instagram.com/username",
                        ),
                        const SizedBox(height: 8),

                        _buildEditableRow(
                          label: "X (Twitter)",
                          isEditing: _isEditing,
                          controller: _xController,
                          displayValue: _profile!.xUrl,
                          hintText: "https://x.com/username",
                        ),
                        const SizedBox(height: 8),

                        _buildEditableRow(
                          label: "Website",
                          isEditing: _isEditing,
                          controller: _websiteController,
                          displayValue: _profile!.websiteUrl,
                          hintText: "https://example.com",
                        ),

                        const SizedBox(height: 24),

                        Text(
                          "Foto Profil (URL)",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _isEditing
                            ? TextFormField(
                                controller: _profilePictureController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "https://...",
                                ),
                              )
                            : Text(_profile!.profilePicture.isEmpty
                                ? "Belum diatur"
                                : _profile!.profilePicture),

                        const SizedBox(height: 24),

                        if (_isEditing)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isSaving ? null : () => _saveProfile(request),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text("Save changes"),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildEditableRow({
    required String label,
    required bool isEditing,
    required TextEditingController controller,
    required String displayValue,
    String? hintText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: isEditing
              ? TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: hintText,
                    isDense: true,
                  ),
                )
              : Text(displayValue.isEmpty ? "-" : displayValue),
        ),
      ],
    );
  }
}
