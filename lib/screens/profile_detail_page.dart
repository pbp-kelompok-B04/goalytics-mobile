import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ProfileDetailPage extends StatefulWidget {
  final String username;

  const ProfileDetailPage({super.key, required this.username});

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  bool _loading = true;
  Map<String, dynamic>? data;

  static const String baseUrl = "http://localhost:8000"; 

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.get(
        "$baseUrl/users/api/profile/${widget.username}/",
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
          SnackBar(content: Text("Failed to load profile")),
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
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: (data!["avatar"] != null &&
                                data!["avatar"].toString().isNotEmpty)
                            ? NetworkImage(data!["avatar"])
                            : null,
                        child: (data!["avatar"] == null ||
                                data!["avatar"].toString().isEmpty)
                            ? Text(
                                widget.username[0].toUpperCase(),
                                style: const TextStyle(fontSize: 40),
                              )
                            : null,
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
                      _infoTile("Preferred Position",
                          data!["preferred_position"]),

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
