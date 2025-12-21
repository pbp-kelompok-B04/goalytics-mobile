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

  // Theme Color (Midnight Blue)
  final Color _themeColor = const Color(0xff1c2341);

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

    if (widget.match != null) {
      _venueController.text = widget.match!.fields.venue;
      _selectedDate = widget.match!.fields.matchDatetime;
    }
  }

  Future<void> _fetchClubs() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('${ApiConfig.baseUrl}/matchprediction/get-clubs/');
      setState(() {
        _clubs = response;
        _isLoading = false;

        if (widget.match != null) {
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _themeColor, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: _themeColor, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();
    final isEdit = widget.match != null;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Background terang
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _themeColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _themeColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Text(
                isEdit ? "Edit Match" : "Create\nNew Match",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _themeColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 30),

              // --- HOME CLUB ---
              _buildLabel("Home Club"),
              _buildDropdownField(
                hint: "Select Home Club",
                value: _selectedHomeClub,
                onChanged: (val) => setState(() => _selectedHomeClub = val),
                validator: (val) => val == null ? "Required" : null,
              ),
              const SizedBox(height: 20),

              // --- AWAY CLUB ---
              _buildLabel("Away Club"),
              _buildDropdownField(
                hint: "Select Away Club",
                value: _selectedAwayClub,
                onChanged: (val) => setState(() => _selectedAwayClub = val),
                validator: (val) {
                  if (val == null) return "Required";
                  if (val == _selectedHomeClub) return "Clubs must be different";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- DATE PICKER ---
              _buildLabel("Match Date"),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, color: _themeColor),
                      const SizedBox(width: 12),
                      Text(
                        "${_selectedDate.toLocal()}".split(' ')[0],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- VENUE ---
              _buildLabel("Venue (Stadium)"),
              TextFormField(
                controller: _venueController,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                decoration: InputDecoration(
                  hintText: "e.g. Emirates Stadium",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _themeColor, width: 2),
                  ),
                ),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 40),

              // --- SUBMIT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
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
                            behavior: SnackBarBehavior.floating,
                          ));
                          Navigator.pop(context, true); // Balik dan refresh
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(response['message'] ?? "Error"),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      }
                    }
                  },
                  child: Text(
                    isEdit ? "Update Match" : "Create Match",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget: Label Teks
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _themeColor,
        ),
      ),
    );
  }

  // Helper Widget: Custom Dropdown
  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint, style: TextStyle(color: Colors.grey[400])),
      items: _clubs.map<DropdownMenuItem<String>>((club) {
        return DropdownMenuItem<String>(
          value: club['id'].toString(),
          child: Text(club['name'], style: TextStyle(color: Colors.grey[800])),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _themeColor, width: 2),
        ),
      ),
      dropdownColor: Colors.white,
    );
  }
}