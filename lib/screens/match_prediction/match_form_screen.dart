import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goalytics_mobile/service/api_config.dart';
import 'package:goalytics_mobile/models/match_model.dart';

class MatchFormScreen extends StatefulWidget {
  final Match? match; // Jika null = Create, Jika ada = Edit

  const MatchFormScreen({super.key, this.match});

  @override
  State<MatchFormScreen> createState() => _MatchFormScreenState();
}

class _MatchFormScreenState extends State<MatchFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Variabel Form
  String? _selectedHomeClub;
  String? _selectedAwayClub;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _venueController = TextEditingController();

  // Data Klub dari Backend
  List<dynamic> _clubs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClubs();

    // Jika Edit Mode, isi form dengan data lama
    if (widget.match != null) {
      _venueController.text = widget.match!.fields.venue;
      _selectedDate = widget.match!.fields.matchDatetime;
      // Note: Mengisi dropdown club agak tricky karena kita butuh ID,
      // tapi model Match kita mungkin cuma menyimpan ID (integer).
      // Kita set nanti setelah fetch clubs selesai.
    }
  }

  Future<void> _fetchClubs() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('${ApiConfig.baseUrl}/matchprediction/get-clubs/');
      setState(() {
        _clubs = response; // List of {id: 1, name: "Arsenal"}
        _isLoading = false;

        // Set initial values for Dropdown if Edit Mode
        if (widget.match != null) {
          // Cari ID klub di list dan set sebagai selected
          // (Asumsi widget.match.fields.homeClub adalah int ID)
          if (widget.match!.fields.homeClub != null) {
            _selectedHomeClub = widget.match!.fields.homeClub.toString();
          }
          if (widget.match!.fields.awayClub != null) {
            _selectedAwayClub = widget.match!.fields.awayClub.toString();
          }
        }
      });
    } catch (e) {
      debugPrint("Error fetching clubs: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.match != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Match" : "Create Match"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HOME CLUB ---
              const Text("Home Club", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _selectedHomeClub,
                hint: const Text("Select Home Club"),
                items: _clubs.map<DropdownMenuItem<String>>((club) {
                  return DropdownMenuItem<String>(
                    value: club['id'].toString(),
                    child: Text(club['name']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedHomeClub = val),
                validator: (val) => val == null ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // --- AWAY CLUB ---
              const Text("Away Club", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _selectedAwayClub,
                hint: const Text("Select Away Club"),
                items: _clubs.map<DropdownMenuItem<String>>((club) {
                  return DropdownMenuItem<String>(
                    value: club['id'].toString(),
                    child: Text(club['name']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedAwayClub = val),
                validator: (val) {
                  if (val == null) return "Required";
                  if (val == _selectedHomeClub) return "Clubs must be different";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- DATE PICKER ---
              const Text("Match Date", style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                title: Text("${_selectedDate.toLocal()}".split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                contentPadding: EdgeInsets.zero,
                onTap: () => _selectDate(context),
              ),
              const Divider(),
              const SizedBox(height: 16),

              // --- VENUE ---
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(
                  labelText: "Venue (Stadium)",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),

              // --- SUBMIT BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Tentukan URL: Create atau Edit
                      String url = isEdit
                          ? "${ApiConfig.baseUrl}/matchprediction/edit-match-flutter/${widget.match!.pk}/"
                          : "${ApiConfig.baseUrl}/matchprediction/create-match-flutter/";

                      final response = await request.postJson(
                        url,
                        jsonEncode(<String, dynamic>{
                          'home_club_id': _selectedHomeClub,
                          'away_club_id': _selectedAwayClub,
                          'venue': _venueController.text,
                          'match_datetime': _selectedDate.toIso8601String(),
                        }),
                      );

                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Match saved successfully!"),
                          ));
                          Navigator.pop(context, true); // Balik dan refresh
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(response['message'] ?? "Error"),
                            backgroundColor: Colors.red,
                          ));
                        }
                      }
                    }
                  },
                  child: Text(isEdit ? "Update Match" : "Create Match"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}