import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goalytics_mobile/models/match_model.dart';
import 'package:goalytics_mobile/models/prediction_model.dart';
import 'package:goalytics_mobile/service/api_config.dart';
import 'package:goalytics_mobile/screens/match_prediction/match_form_screen.dart'; // Import Form Screen

class MatchDetailScreen extends StatefulWidget {
  final Match match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  String _sortOption = 'newest';
  bool _isManager = false;

  final TextEditingController _homeScoreController = TextEditingController();
  final TextEditingController _awayScoreController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();

  bool _isLoadingUserPrediction = true;
  bool _hasPrediction = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _fetchUserPrediction();
      _fetchUserRole();
    });
  }

  @override
  void dispose() {
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserRole() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('${ApiConfig.baseUrl}/matchprediction/get-role/');
      if (mounted) {
        setState(() {
          _isManager = response['is_manager'] ?? false;
        });
      }
    } catch (e) {
      debugPrint("Error checking role: $e");
    }
  }

  Future<void> _fetchUserPrediction() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
          '${ApiConfig.baseUrl}/matchprediction/json/${widget.match.pk}/my-prediction/'
      );

      if (response is List && response.isNotEmpty) {
        final prediction = Prediction.fromJson(response[0]);
        setState(() {
          _homeScoreController.text = prediction.fields.predictedHomeScore.toString();
          _awayScoreController.text = prediction.fields.predictedAwayScore.toString();
          _explanationController.text = prediction.fields.explanation;
          _hasPrediction = true;
        });
      } else {
        setState(() {
          _hasPrediction = false;
        });
      }
    } catch (e) {
      setState(() { _hasPrediction = false; });
    } finally {
      setState(() {
        _isLoadingUserPrediction = false;
      });
    }
  }

  Future<List<Prediction>> fetchPredictions(CookieRequest request) async {
    final response = await request.get('${ApiConfig.baseUrl}/matchprediction/json/${widget.match.pk}/predictions/?sort_by=$_sortOption');
    List<Prediction> listPrediction = [];
    for (var d in response) {
      if (d != null) {
        listPrediction.add(Prediction.fromJson(d));
      }
    }
    return listPrediction;
  }

  // --- FUNGSI BARU: DELETE MATCH (ADMIN) ---
  Future<void> _deleteMatch(CookieRequest request) async {
    final response = await request.post(
        "${ApiConfig.baseUrl}/matchprediction/delete-match-flutter/${widget.match.pk}/",
        {}
    );
    if (mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Match deleted successfully!"),
        ));
        Navigator.pop(context, true); // Kembali ke list & refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message'] ?? "Error deleting match"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.match.fields.homeClubName ?? 'Home'} vs ${widget.match.fields.awayClubName ?? 'Away'}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,

        // 👇 TOMBOL AKSI KHUSUS ADMIN (EDIT & DELETE MATCH)
        actions: [
          if (_isManager) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: "Edit Match",
              onPressed: () async {
                // Buka Form Edit
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchFormScreen(match: widget.match),
                  ),
                );
                // Jika berhasil edit (result == true), kembali ke list agar data ter-refresh
                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: "Delete Match",
              onPressed: () {
                // Konfirmasi Hapus
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Match"),
                    content: const Text("Are you sure you want to delete this match? This action cannot be undone."),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      TextButton(
                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _deleteMatch(request);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ]
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian Form Prediksi ---
            const Text(
              "Your Prediction",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (_isLoadingUserPrediction)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ))
            else
              Form(
                key: _formKey,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _homeScoreController,
                                decoration: const InputDecoration(labelText: 'Home Score'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Required';
                                  if (int.tryParse(value) == null) return 'Must be number';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _awayScoreController,
                                decoration: const InputDecoration(labelText: 'Away Score'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Required';
                                  if (int.tryParse(value) == null) return 'Must be number';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _explanationController,
                          decoration: const InputDecoration(labelText: 'Why? (Explanation)'),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter an explanation';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_hasPrediction)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final response = await request.post(
                                        "${ApiConfig.baseUrl}/matchprediction/delete-flutter/${widget.match.pk}/",
                                        {}
                                    );
                                    if (context.mounted) {
                                      if (response['status'] == 'success') {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          content: Text("Prediction deleted successfully!"),
                                        ));
                                        setState(() {
                                          _homeScoreController.clear();
                                          _awayScoreController.clear();
                                          _explanationController.clear();
                                          _hasPrediction = false;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text(response['message'] ?? "Error deleting"),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                    }
                                  },
                                  child: const Text("Delete"),
                                ),
                              ),

                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final response = await request.postJson(
                                    "${ApiConfig.baseUrl}/matchprediction/create-flutter/${widget.match.pk}/",
                                    jsonEncode(<String, dynamic>{
                                      'predicted_home_score': int.parse(_homeScoreController.text),
                                      'predicted_away_score': int.parse(_awayScoreController.text),
                                      'explanation': _explanationController.text,
                                    }),
                                  );

                                  if (context.mounted) {
                                    if (response['status'] == 'success') {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text(response['message']),
                                      ));
                                      setState(() { _hasPrediction = true; });
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text(response['message'] ?? "Error saving prediction"),
                                        backgroundColor: Colors.red,
                                      ));
                                    }
                                  }
                                }
                              },
                              child: const Text("Save Prediction"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 10),

            // --- Bagian List Prediksi Komunitas ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Community Predictions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _sortOption,
                  items: const [
                    DropdownMenuItem(
                      value: 'newest',
                      child: Text("Newest"),
                    ),
                    DropdownMenuItem(
                      value: 'upvotes',
                      child: Text("Most Upvoted"),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _sortOption = newValue;
                      });
                    }
                  },
                  style: const TextStyle(color: Colors.indigo, fontSize: 14),
                  underline: Container(
                    height: 2,
                    color: Colors.indigoAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            FutureBuilder(
              future: fetchPredictions(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return const Text("No predictions yet. Be the first!");
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) {
                      Prediction p = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text("${p.fields.predictedHomeScore}-${p.fields.predictedAwayScore}"),
                          ),
                          title: Text(
                            p.fields.username ?? "User ${p.fields.user}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(p.fields.explanation),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isManager)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () async {
                                    // Konfirmasi Hapus
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Delete Prediction"),
                                        content: const Text("Remove this user's prediction?"),
                                        actions: [
                                          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(ctx, false)),
                                          TextButton(child: const Text("Delete", style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true)),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      // Panggil Endpoint Baru
                                      final response = await request.post(
                                          "${ApiConfig.baseUrl}/matchprediction/admin-delete-prediction/${p.pk}/",
                                          {}
                                      );

                                      if (context.mounted) {
                                        if (response['status'] == 'success') {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                            content: Text("Prediction removed."),
                                          ));
                                          setState(() {}); // Refresh list
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                            content: Text("Failed to delete."),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      }
                                    }
                                  },
                                ),

                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      final response = await request.post(
                                        "${ApiConfig.baseUrl}/matchprediction/ajax/prediction/${p.pk}/upvote/",
                                        {},
                                      );

                                      if (context.mounted) {
                                        if (response['status'] == 'success') {
                                          setState(() {
                                            p.fields.upvoteCount = response['new_count'];
                                            p.fields.userHasUpvoted = response['is_upvoted'];
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                            content: Text("Failed to upvote. Login might be required."),
                                          ));
                                        }
                                      }
                                    },
                                    child: Icon(
                                      p.fields.userHasUpvoted
                                          ? Icons.thumb_up
                                          : Icons.thumb_up_outlined,
                                      size: 24,
                                      color: p.fields.userHasUpvoted
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${p.fields.upvoteCount}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}