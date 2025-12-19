import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../models/rumour_entry.dart';
import 'rumour_form.dart';
import 'rumour_list.dart';
import '../../widgets/left_drawer.dart';


class RumourDetailPage extends StatelessWidget {
  final RumourEntry rumour;

  const RumourDetailPage({super.key, required this.rumour});

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      drawer: const LeftDrawer(),
      appBar: AppBar(
        title: const Text('Detail Rumour'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final refresh = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => RumourFormPage(
                    existingRumour: rumour,
                  ),
                ),
              );
              if (refresh == true && context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RumourListPage(),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Rumour'),
                  content: const Text(
                      'Apakah kamu yakin ingin menghapus rumour ini?'),
                  actions: [
                    TextButton(
                      child: const Text('Batal'),
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                    TextButton(
                      child: const Text('Hapus'),
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              final url =
                  'https://jefferson-tirza-goalytics.pbp.cs.ui.ac.id/transfer-rumours/${rumour.slug}/delete-flutter/';

              final response = await request.postJson(
                url,
                jsonEncode({}), 
              );

              if (context.mounted) {
                if (response['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rumour berhasil dihapus'),
                    ),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RumourListPage(),
                    ),
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Gagal menghapus rumour: ${response['message'] ?? ''}'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rumour.coverImageUrl.isNotEmpty)
              Image.network(
                rumour.coverImageUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 220,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rumour.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (rumour.authorUsername != null)
                        Text(
                          'By ${rumour.authorUsername}',
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                      if (rumour.authorUsername != null) const SizedBox(width: 10),
                      Text(
                        _formatDate(rumour.createdAt),
                        style:
                            TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (rumour.summary.isNotEmpty) ...[
                    Text(
                      rumour.summary,
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    rumour.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  if (rumour.sourceUrl.isNotEmpty)
                    Text(
                      'Source: ${rumour.sourceUrl}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[700],
                        decoration: TextDecoration.underline,
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
