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

  String _formatDateTime(DateTime dt) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  String _extractSource(RumourEntry rumour) {
    if (rumour.sourceUrl.trim().isEmpty) {
      return 'Tidak diketahui';
    }
    try {
      final uri = Uri.parse(rumour.sourceUrl);
      if (uri.host.isNotEmpty) {
        return uri.host.replaceFirst('www.', '');
      }
    } catch (_) {}
    return rumour.sourceUrl;
  }

  Widget _buildChip({
    required String label,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTopRumourCard(BuildContext context, RumourEntry rumour) {
    final source = _extractSource(rumour);
    final dateText = _formatDateTime(rumour.createdAt);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RumourDetailPage(rumour: rumour),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar + overlay tanggal dan chip "TOP RUMOUR"
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: rumour.coverImageUrl.isNotEmpty
                        ? Image.network(
                            rumour.coverImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.broken_image),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: _buildChip(
                    label: dateText,
                    backgroundColor: Colors.black.withOpacity(0.7),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: _buildChip(
                    label: 'TOP RUMOUR',
                    backgroundColor: Colors.black87,
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rumour.title,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sumber: $source',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rumour.summary.isNotEmpty
                        ? rumour.summary
                        : rumour.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: Colors.grey[800],
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

  Widget _buildSmallRumourCard(
      BuildContext context, RumourEntry rumour, int index) {
    final source = _extractSource(rumour);
    final dateText = _formatDateTime(rumour.createdAt);

    // simple: item2 & seterusnya label "RUMOUR"
    final statusLabel = 'RUMOUR';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RumourDetailPage(rumour: rumour),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail gambar
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 88,
                height: 60,
                child: rumour.coverImageUrl.isNotEmpty
                    ? Image.network(
                        rumour.coverImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 20),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 20),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // baris status + tanggal
                  Row(
                    children: [
                      _buildChip(
                        label: statusLabel,
                        backgroundColor: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dateText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rumour.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sumber: $source',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
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

  Future<void> _goToNewRumourForm(BuildContext context) async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RumourFormPage(),
      ),
    );
    if (refresh == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOP NEWS',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              // Judul + tombol New Rumour
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      'Transfer Rumours',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: () => _goToNewRumourForm(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                    ),
                    label: const Text(
                      'New Rumour',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Deskripsi
              Text(
                'The latest moves, whispers, and confirmed deals curated by the Goalytics newsroom.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 18),
              // List rumour
              Expanded(
                child: FutureBuilder<List<RumourEntry>>(
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
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: rumours.length,
                      itemBuilder: (context, index) {
                        final rumour = rumours[index];
                        if (index == 0) {
                          return _buildTopRumourCard(context, rumour);
                        }
                        return _buildSmallRumourCard(context, rumour, index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // FAB dihapus supaya layout mirip Figma
    );
  }
}
