import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../models/ProfileEntry.dart';
import '../../service/api_config.dart';
import 'package:goalytics_mobile/widgets/bottom_nav.dart'; 


String formatJoinedMonthYear(String iso) {
  final raw = iso.trim();
  if (raw.isEmpty) return "-";

  final dt = DateTime.tryParse(raw);
  if (dt == null) return "-";

  const months = [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December"
  ];

  final m = months[dt.month - 1];
  return "$m ${dt.year}";
}

String prettyRole(String roleRaw) {
  final r = roleRaw.trim();
  if (r.isEmpty) return "User";
  return r[0].toUpperCase() + r.substring(1);
}

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
  double radius = 32,
}) {
  final url = proxiedImageUrl(imageUrl);
  if (url.isEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: Text(
        fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : "?",
        style: TextStyle(fontSize: radius * 0.75, color: Colors.black),
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
              style: TextStyle(fontSize: radius * 0.75, color: Colors.black),
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
  List<Map<String, dynamic>> _clubs = [];
  List<String> _leagues = [];
  int? _selectedClubId;
  String? _selectedLeague;
  bool _loadingDropdowns = false;
  ProfileEntry? _profile;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _favoriteTeamController = TextEditingController();
  final TextEditingController _favoriteLeagueController =
      TextEditingController();
  final TextEditingController _preferredPositionController =
      TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _profilePictureController =
      TextEditingController();

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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat profil: $e")),
      );
    }
  }

  Future<void> _loadDropdownData(CookieRequest request) async {
  setState(() => _loadingDropdowns = true);
  try {
    final clubsRes = await request.get("${ApiConfig.baseUrl}/data/api/clubs/");
    final leaguesRes = await request.get("${ApiConfig.baseUrl}/data/api/leagues/");

    _clubs = List<Map<String, dynamic>>.from(clubsRes["data"] ?? []);
    _leagues = List<String>.from(leaguesRes["results"] ?? []);
  } finally {
    if (mounted) setState(() => _loadingDropdowns = false);
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
      ..profilePicture = _profilePictureController.text.trim()
      ..favoriteTeamId = _selectedClubId
      ..favoriteLeague = _selectedLeague ?? "";

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
      backgroundColor: const Color(0xFFF4F5F7),
      bottomNavigationBar: const BottomNav(),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _profile == null
                ? const Center(child: Text("Gagal memuat profil."))
                : Form(
                    key: _formKey,
                    child: Stack(
                      children: [
                        Container(
                          height: 170,
                          width: double.infinity,
                          color: Colors.black,
                        ),

                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 68, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ProfileHeroCard(
                                profile: _profile!,
                                isEditing: _isEditing,
                                onToggleEdit: () async {
                                  setState(() => _isEditing = !_isEditing);
                                  if (_isEditing) {
                                    final request = context.read<CookieRequest>();
                                    await _loadDropdownData(request);

                                    setState(() {
                                      _selectedClubId = _profile?.favoriteTeamId;
                                      _selectedLeague = (_profile?.favoriteLeague.isNotEmpty ?? false)
                                          ? _profile!.favoriteLeague
                                          : null;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),

                              if (_isEditing) ...[
                                _SectionCard(
                                  title: "Edit Profile",
                                  child: Column(
                                    children: [
                                      _LabeledField(
                                        label: "Bio",
                                        child: TextFormField(
                                          controller: _bioController,
                                          maxLines: 3,
                                          decoration: const InputDecoration(
                                            hintText: "Tulis bio kamu...",
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _LabeledField(
                                        label: "Tim favorit",
                                        child: DropdownButtonFormField<int>(
                                          value: _selectedClubId,
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          hint: const Text("Pilih klub"),
                                          items: _clubs.map((c) {
                                            final id = c["id"] as int;
                                            final name = (c["name"] ?? "").toString();
                                            return DropdownMenuItem<int>(
                                              value: id,
                                              child: Text(name),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            setState(() => _selectedClubId = val);
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _LabeledField(
                                        label: "Liga favorit",
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedLeague,
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          hint: const Text("Pilih liga"),
                                          items: _leagues.map((lg) {
                                            return DropdownMenuItem<String>(
                                              value: lg,
                                              child: Text(lg),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            setState(() => _selectedLeague = val);
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _LabeledField(
                                        label: "Posisi favorit",
                                        child: TextFormField(
                                          controller:
                                              _preferredPositionController,
                                          decoration: const InputDecoration(
                                            hintText: "Contoh: Winger",
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _LabeledField(
                                        label: "Instagram",
                                        child: TextFormField(
                                          controller: _instagramController,
                                          decoration: const InputDecoration(
                                            hintText:
                                                "https://instagram.com/username",
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _LabeledField(
                                        label: "X (Twitter)",
                                        child: TextFormField(
                                          controller: _xController,
                                          decoration: const InputDecoration(
                                            hintText: "https://x.com/username",
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _LabeledField(
                                        label: "Website",
                                        child: TextFormField(
                                          controller: _websiteController,
                                          decoration: const InputDecoration(
                                            hintText: "https://example.com",
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _LabeledField(
                                        label: "Foto Profil (URL)",
                                        child: TextFormField(
                                          controller:
                                              _profilePictureController,
                                          decoration: const InputDecoration(
                                            hintText: "https://...",
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF101828),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: _isSaving
                                              ? null
                                              : () => _saveProfile(request),
                                          child: _isSaving
                                              ? const SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Text("Save changes"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                _SectionCard(
                                  title: "Preferensi Sepak Bola",
                                  child: Column(
                                    children: [
                                      _InfoRow(
                                        label: "Tim favorit",
                                        value: _profile!.favoriteTeam,
                                      ),
                                      const SizedBox(height: 8),
                                      _InfoRow(
                                        label: "Liga favorit",
                                        value: _profile!.favoriteLeague,
                                      ),
                                      const SizedBox(height: 8),
                                      _InfoRow(
                                        label: "Posisi favorit",
                                        value: _profile!.preferredPosition,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _SectionCard(
                                  title: "Media Sosial",
                                  child: Column(
                                    children: [
                                      _InfoRow(
                                        label: "Instagram",
                                        value: _profile!.instagramUrl,
                                      ),
                                      const SizedBox(height: 8),
                                      _InfoRow(
                                        label: "X",
                                        value: _profile!.xUrl,
                                      ),
                                      const SizedBox(height: 8),
                                      _InfoRow(
                                        label: "Website",
                                        value: _profile!.websiteUrl,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}


class _ProfileHeroCard extends StatelessWidget {
  final ProfileEntry profile;
  final bool isEditing;
  final VoidCallback onToggleEdit;

  const _ProfileHeroCard({
    required this.profile,
    required this.isEditing,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    final roleText = prettyRole(profile.role);
    final joinedText =
        "Joined ${formatJoinedMonthYear(profile.memberSince)}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profileAvatar(
                imageUrl: profile.profilePicture,
                fallbackText: profile.username,
                radius: 36,
              ),
              const Spacer(),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF101828),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    elevation: 0,
                  ),
                  onPressed: onToggleEdit,
                  icon:
                      Icon(isEditing ? Icons.close : Icons.edit, size: 18),
                  label: Text(isEditing ? "Close" : "Edit Profile"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            "@${profile.username}",
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF667085),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              roleText,
              style: const TextStyle(
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            profile.bio.isEmpty ? "Belum ada bio" : profile.bio,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF344054),
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.calendar_month,
                  size: 18, color: Color(0xFF667085)),
              const SizedBox(width: 8),
              Text(
                joinedText,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF667085),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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
              color: Color(0xFF101828),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value.isEmpty ? "-" : value,
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

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF101828),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
