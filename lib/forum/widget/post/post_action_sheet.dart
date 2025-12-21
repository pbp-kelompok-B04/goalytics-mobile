import 'package:flutter/material.dart';

class PostActionSheet extends StatelessWidget {
  const PostActionSheet({
    super.key,
    required this.title,
    required this.controller,
    required this.onSubmit,
    required this.primaryLabel,
    this.label, 
  });

  final String title;
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final String primaryLabel;
  final String? label;

  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate900 = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // rounded-3xl
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000), 
            blurRadius: 25,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: slate200, width: 1), 
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.w600, 
                    color: slate900,
                  ),
                ),
                
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: slate100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFF64748B), 
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null) ...[
                  Text(
                    label!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: slate400,
                      letterSpacing: 0.5, 
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                TextField(
                  controller: controller,
                  maxLines: 4,
                  minLines: 3,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF334155), 
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your reply...',
                    hintStyle: const TextStyle(color: slate400),
                    filled: true,
                    fillColor: slate50, 
                    contentPadding: const EdgeInsets.all(16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: slate200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: slate400, width: 1.5),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24), 

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                  
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), 
                          side: const BorderSide(color: slate200), 
                        ),
                        foregroundColor: slate600,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    ElevatedButton(
                      onPressed: onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: slate900, 
                        foregroundColor: Colors.white,
                        elevation: 2, 
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), 
                        ),
                      ),
                      child: Text(
                        primaryLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}