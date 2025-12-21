import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/rumour_entry.dart';

class RumourFormPage extends StatefulWidget {
  final RumourEntry? existingRumour;

  const RumourFormPage({super.key, this.existingRumour});

  @override
  State<RumourFormPage> createState() => _RumourFormPageState();
}

class _RumourFormPageState extends State<RumourFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  late TextEditingController _contentController;
  late TextEditingController _sourceUrlController;
  late TextEditingController _coverImageUrlController;

  bool get isEdit => widget.existingRumour != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingRumour?.title ?? '',
    );
    _summaryController = TextEditingController(
      text: widget.existingRumour?.summary ?? '',
    );
    _contentController = TextEditingController(
      text: widget.existingRumour?.content ?? '',
    );
    _sourceUrlController = TextEditingController(
      text: widget.existingRumour?.sourceUrl ?? '',
    );
    _coverImageUrlController = TextEditingController(
      text: widget.existingRumour?.coverImageUrl ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _sourceUrlController.dispose();
    _coverImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final request = context.read<CookieRequest>();

    final payload = {
      'title': _titleController.text.trim(),
      'summary': _summaryController.text.trim(),
      'content': _contentController.text.trim(),
      'source_url': _sourceUrlController.text.trim(),
      'cover_image_url': _coverImageUrlController.text.trim(),
    };

    final baseUrl =
        'https://jefferson-tirza-goalytics.pbp.cs.ui.ac.id/transfer-rumours';

    final url = isEdit
        ? '$baseUrl/${widget.existingRumour!.slug}/update-flutter/'
        : '$baseUrl/create-flutter/';

    final response = await request.postJson(url, jsonEncode(payload));

    if (!mounted) return;

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Rumour berhasil diperbarui.' : 'Rumour berhasil dibuat.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } else {
      final msg = response['message'] ?? 'Terjadi kesalahan.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan rumour: $msg')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = isEdit ? 'Edit Rumour' : 'Tambah Rumour';

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _summaryController,
                    decoration: const InputDecoration(
                      labelText: 'Summary (opsional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Konten',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 6,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Konten tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _sourceUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Source URL (opsional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _coverImageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Cover Image URL (opsional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submit(context),
                      child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Rumour'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
