import 'package:flutter/material.dart';
import 'package:goalytics_mobile/forum/models/forum_models.dart';
import 'package:goalytics_mobile/forum/screens/post_detail_screen.dart';
import 'package:goalytics_mobile/forum/widget/post/post_helpers.dart';

class ForumNotificationSheet extends StatelessWidget {
  const ForumNotificationSheet({
    super.key,
    required this.notifications,
    required this.onMarkRead,
  });

  final List<ForumNotification> notifications;
  final VoidCallback onMarkRead;

  // Palet Warna Tailwind Slate
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate900 = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Menyesuaikan tinggi maksimal agar tidak terlalu penuh
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // rounded-3xl
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Section ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18, // text-lg
                    fontWeight: FontWeight.w600, // font-semibold
                    color: slate900,
                  ),
                ),
                // Tombol Close (Bulat seperti di HTML)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: slate100, // bg-slate-100
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: slate500, // text-slate-500
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: slate200), // Border bottom header

          // --- List Section ---
          Flexible(
            child: notifications.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No notifications yet.',
                        style: TextStyle(color: slate400),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      // Item Style: rounded-2xl border border-slate-200 bg-slate-50
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: n.isRead ? slate50 : Colors.white,
                          borderRadius: BorderRadius.circular(16), // rounded-2xl
                          border: Border.all(
                            color: n.isRead ? slate200 : const Color(0xFFCBD5E1),
                          ),
                          // Efek hover diwakili oleh sedikit shadow jika belum dibaca
                          boxShadow: n.isRead
                              ? []
                              : [
                                  BoxShadow(
                                    color: slate900.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                        ),
                        child: InkWell(
                          onTap: () {
                            if (n.postId != null) {
                              Navigator.pop(context); // Close the sheet
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailScreen(
                                    postId: n.postId!,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('This notification has no target post'),
                                ),
                              );
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Rich Text: Actor (Bold) + Verb
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: slate700,
                                    height: 1.4,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: n.actor,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600, // font-semibold
                                        color: slate900,
                                      ),
                                    ),
                                    TextSpan(text: ' ${n.verb}'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Date
                              Text(
                                postTimeAgo(n.createdAt), // format waktu
                                style: const TextStyle(
                                  fontSize: 12, // text-xs
                                  color: slate400, // text-slate-400
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Opsional: Tombol "Mark all read" disembunyikan agar visual match HTML.
          // Namun, jika ingin fungsi itu berjalan otomatis saat dibuka (seperti JS),
          // Anda bisa memanggil `onMarkRead()` di parent widget atau di initState stateful widget.
        ],
      ),
    );
  }
}