import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goalytics_mobile/models/match_model.dart';
import 'package:goalytics_mobile/models/prediction_model.dart';
import 'package:goalytics_mobile/service/api_config.dart';
import 'package:goalytics_mobile/screens/match_prediction/match_form_screen.dart';

class MatchDetailScreen extends StatefulWidget {
  final Match match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color _themeColor = const Color(0xff1c2341); // Warna Tema

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
        Navigator.pop(context, true);
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

    // Nama Klub (Handle TBD jika data belum masuk)
    String homeName = widget.match.fields.homeClubName ?? 'Home';
    String awayName = widget.match.fields.awayClubName ?? 'Away';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true, // Agar AppBar transparan di atas header berwarna
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Admin Actions (Edit/Delete Match)
          if (_isManager) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: "Edit Match",
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchFormScreen(match: widget.match),
                  ),
                );
                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              tooltip: "Delete Match",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Match"),
                    content: const Text("Are you sure? This cannot be undone."),
                    actions: [
                      TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(ctx)),
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
        child: Column(
          children: [
            // 1. & 2. HEADER SECTION (Match Info)
            _buildMatchHeader(homeName, awayName),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 3. PREDICTION FORM
                  _buildPredictionForm(request, homeName, awayName),

                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 20),

                  // 4. COMMUNITY PREDICTIONS TITLE
                  Text(
                    "Community Predictions",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _themeColor
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 5. FILTER BUTTON
                  _buildFilterDropdown(),

                  const SizedBox(height: 20),

                  // 6. LIST PREDICTIONS
                  FutureBuilder(
                    future: fetchPredictions(request),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                        return Column(
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 8),
                            const Text("No predictions yet. Be the first!", style: TextStyle(color: Colors.grey)),
                          ],
                        );
                      } else {
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, index) {
                            Prediction p = snapshot.data![index];
                            return _buildPredictionCard(request, p);
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildMatchHeader(String homeName, String awayName) {
    // Format Tanggal
    String rawDate = widget.match.fields.matchDatetime.toString();
    String date = rawDate.length > 10 ? rawDate.substring(0, 10) : rawDate;
    String time = rawDate.length > 16 ? rawDate.substring(11, 16) : "";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 30), // Padding atas besar untuk kompensasi AppBar transparan
      decoration: BoxDecoration(
        color: _themeColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: _themeColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          // Info Tanggal & Venue
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text("$date • $time", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(width: 10),
                const Icon(Icons.stadium, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text(widget.match.fields.venue, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Match Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  homeName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "VS",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 20, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900),
                ),
              ),
              Expanded(
                child: Text(
                  awayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionForm(CookieRequest request, String homeName, String awayName) {
    if (_isLoadingUserPrediction) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            Text(
              _hasPrediction ? "Edit Your Prediction" : "Make a Prediction",
              style: TextStyle(color: _themeColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Score Inputs
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(homeName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _homeScoreController,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _themeColor),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "0",
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (val) => val == null || val.isEmpty ? "" : null, // Minimal validation visual
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Text("-", style: TextStyle(fontSize: 30, color: Colors.grey)),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(awayName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _awayScoreController,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _themeColor),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "0",
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (val) => val == null || val.isEmpty ? "" : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Explanation Input
            TextFormField(
              controller: _explanationController,
              decoration: InputDecoration(
                labelText: "Match Analysis",
                hintText: "Share your reasoning or gut feeling...",
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
              validator: (value) => value == null || value.isEmpty ? 'Please share your reasoning' : null,
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                if (_hasPrediction) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final response = await request.post(
                            "${ApiConfig.baseUrl}/matchprediction/delete-flutter/${widget.match.pk}/", {});
                        if (context.mounted && response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Prediction deleted!")));
                          setState(() {
                            _homeScoreController.clear();
                            _awayScoreController.clear();
                            _explanationController.clear();
                            _hasPrediction = false;
                          });
                        }
                      },
                      child: const Text("Delete"),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _themeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
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
                        if (context.mounted && response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
                          setState(() { _hasPrediction = true; });
                        }
                      }
                    },
                    child: Text(_hasPrediction ? "Update" : "Predict"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortOption,
          icon: Icon(Icons.sort, color: _themeColor),
          items: const [
            DropdownMenuItem(value: 'newest', child: Text("Newest First")),
            DropdownMenuItem(value: 'upvotes', child: Text("Most Upvoted")),
          ],
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _sortOption = newValue;
              });
            }
          },
          style: TextStyle(color: _themeColor, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildPredictionCard(CookieRequest request, Prediction p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header: User & Admin Delete
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: _themeColor.withOpacity(0.1),
                  child: Icon(Icons.person, size: 16, color: _themeColor),
                ),
                const SizedBox(width: 8),
                Text(
                  p.fields.username ?? "User ${p.fields.user}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                ),
                const Spacer(),
                if (_isManager)
                  InkWell(
                    onTap: () async {
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
                        final response = await request.post("${ApiConfig.baseUrl}/matchprediction/admin-delete-prediction/${p.pk}/", {});
                        if (context.mounted && response['status'] == 'success') {
                          setState(() {});
                        }
                      }
                    },
                    child: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Score Badge (Centerpiece)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${p.fields.predictedHomeScore} - ${p.fields.predictedAwayScore}",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _themeColor, letterSpacing: 2),
              ),
            ),
            const SizedBox(height: 12),

            // Explanation
            SizedBox(
              width: double.infinity,
              child: Text(
                p.fields.explanation,
                style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // Footer: Upvote
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () async {
                    final response = await request.post("${ApiConfig.baseUrl}/matchprediction/ajax/prediction/${p.pk}/upvote/", {});
                    if (context.mounted && response['status'] == 'success') {
                      setState(() {
                        p.fields.upvoteCount = response['new_count'];
                        p.fields.userHasUpvoted = response['is_upvoted'];
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        p.fields.userHasUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 18,
                        color: p.fields.userHasUpvoted ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${p.fields.upvoteCount}",
                        style: TextStyle(color: p.fields.userHasUpvoted ? Colors.blue : Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}