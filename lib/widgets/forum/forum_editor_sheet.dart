import 'package:flutter/material.dart';
import 'package:goalytics_mobile/widgets/post/post_helpers.dart';

class ForumEditorResult {
  ForumEditorResult({
    required this.title,
    required this.content,
    required this.league,
    this.mediaUrl,
    this.attachmentUrl,
  });

  final String title;
  final String content;
  final String league;
  final String? mediaUrl;
  final String? attachmentUrl;
}

class ForumEditorSheet extends StatefulWidget {
  const ForumEditorSheet({
    super.key,
    this.initialTitle = '',
    this.initialContent = '',
    this.initialLeague = 'EPL',
    this.initialMediaUrl,
    this.initialAttachmentUrl,
  });

  final String initialTitle;
  final String initialContent;
  final String initialLeague;
  final String? initialMediaUrl;
  final String? initialAttachmentUrl;

  @override
  State<ForumEditorSheet> createState() => _ForumEditorSheetState();
}

class _ForumEditorSheetState extends State<ForumEditorSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _mediaCtrl;
  late final TextEditingController _attachmentCtrl;
  late String _league;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialTitle);
    _contentCtrl = TextEditingController(text: widget.initialContent);
    _mediaCtrl = TextEditingController(text: widget.initialMediaUrl ?? '');
    _attachmentCtrl =
        TextEditingController(text: widget.initialAttachmentUrl ?? '');
    _league = widget.initialLeague;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _mediaCtrl.dispose();
    _attachmentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initialTitle.isEmpty ? 'Create New Post' : 'Edit Post',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DropdownField(
              value: _league,
              onChanged: (val) {
                if (val != null) setState(() => _league = val);
              },
            ),
            const SizedBox(height: 12),
            _TextField(
              controller: _titleCtrl,
              label: 'Title',
              hint: "What's on your mind?",
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            _TextField(
              controller: _contentCtrl,
              label: 'Content',
              hint: 'Share your thoughts with the community...',
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            _TextField(
              controller: _mediaCtrl,
              label: 'Media URL (optional)',
              hint: 'Paste image/video link (e.g. YouTube)',
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            _TextField(
              controller: _attachmentCtrl,
              label: 'Attachment URL (optional)',
              hint: 'Paste image/video link for attachment',
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (_titleCtrl.text.trim().isEmpty ||
                        _contentCtrl.text.trim().isEmpty) {
                      return;
                    }
                    Navigator.of(context).pop(
                      ForumEditorResult(
                        title: _titleCtrl.text.trim(),
                        content: _contentCtrl.text.trim(),
                        league: _league,
                        mediaUrl: _mediaCtrl.text.trim().isEmpty
                            ? null
                            : _mediaCtrl.text.trim(),
                        attachmentUrl: _attachmentCtrl.text.trim().isEmpty
                            ? null
                            : _attachmentCtrl.text.trim(),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.maxLines,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'League',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: const [
            DropdownMenuItem(value: 'EPL', child: Text('Premier League')),
            DropdownMenuItem(value: 'LALIGA', child: Text('La Liga')),
            DropdownMenuItem(value: 'SERIEA', child: Text('Serie A')),
            DropdownMenuItem(value: 'BUNDES', child: Text('Bundesliga')),
            DropdownMenuItem(value: 'LIGUE1', child: Text('Ligue 1')),
          ],
        ),
      ],
    );
  }
}
