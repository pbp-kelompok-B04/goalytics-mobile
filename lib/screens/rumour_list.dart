import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/rumour_entry.dart';
import 'rumour_detail.dart';
import 'rumour_form.dart';

class RumourListPage extends StatefulWidget {
  const RumourListPage({super.key});

  @override
  State<RumourListPage> createState() => _RumourListPageState();
}

class _RumourListPageState extends State<RumourListPage> {
  Future<List<RumourEntry>> fetchRumours(CookieRequest request) async {
    final response =
        await request.get('http://localhost:8000//transfer-rumours/json/');

    List<RumourEntry> rumourList = [];
    for (var item in response) {
      if (item != null) {
        rumourList.add(RumourEntry.fromJson(item));
      }
    }
    return rumourList;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Rumours'),
      ),
      body: FutureBuilder<List<RumourEntry>>(
        future: fetchRumours(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada transfer rumour.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final rumours = snapshot.data!;

          return ListView.builder(
            itemCount: rumours.length,
            itemBuilder: (context, index) {
              final rumour = rumours[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: rumour.coverImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          rumour.coverImageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      )
                    : const Icon(Icons.sports_soccer),
                title: Text(
                  rumour.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  rumour.summary.isNotEmpty
                      ? rumour.summary
                      : rumour.content.length > 80
                          ? '${rumour.content.substring(0, 80)}...'
                          : rumour.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RumourDetailPage(rumour: rumour),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah rumour',
        onPressed: () async {
          final refresh = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const RumourFormPage(),
            ),
          );
          if (refresh == true && mounted) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
