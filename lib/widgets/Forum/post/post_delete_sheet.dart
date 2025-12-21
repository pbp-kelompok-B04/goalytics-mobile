import 'package:flutter/material.dart';

class GenericDeleteSheet extends StatelessWidget {
  const GenericDeleteSheet({
    super.key,
    required this.title, 
    required this.description,
    required this.onConfirm,
    this.confirmLabel = 'Delete',
    this.cancelLabel = 'Cancel',
  });

  final String title;
  final String description;
  final VoidCallback onConfirm;
  final String confirmLabel;
  final String cancelLabel;

  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color rose500 = Color(0xFFF43F5E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w600,
              color: slate900,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: slate500,
              height: 1.5,
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
                child: Text(
                  cancelLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: rose500,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: rose500.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  confirmLabel,
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
    );
  }
}