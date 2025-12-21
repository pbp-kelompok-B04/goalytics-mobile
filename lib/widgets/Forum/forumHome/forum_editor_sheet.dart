import 'package:flutter/material.dart';

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

  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate900 = Color(0xFF0F172A);

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

  void _onSubmit() {
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
      return;
    }
    Navigator.of(context).pop(
      ForumEditorResult(
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        league: _league,
        mediaUrl:
            _mediaCtrl.text.trim().isEmpty ? null : _mediaCtrl.text.trim(),
        attachmentUrl: _attachmentCtrl.text.trim().isEmpty
            ? null
            : _attachmentCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.initialTitle.isNotEmpty;

    return Container(
      
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)), 
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Header ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: slate200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Post' : 'Create New Post',
                  style: const TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w600, 
                    color: slate900,
                  ),
                ),
              
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: slate100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20, color: slate600),
                  ),
                ),
              ],
            ),
          ),

          // --- Form Content (Scrollable) ---
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // League Dropdown
                  _TailwindLabel(label: 'League'),
                  _TailwindDropdown(
                    value: _league,
                    onChanged: (val) {
                      if (val != null) setState(() => _league = val);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Title Input
                  _TailwindLabel(label: 'Title'),
                  _TailwindInput(
                    controller: _titleCtrl,
                    hint: "What's on your mind?",
                  ),
                  const SizedBox(height: 20),

                  // Content Input
                  _TailwindLabel(label: 'Content'),
                  _TailwindInput(
                    controller: _contentCtrl,
                    hint: 'Share your thoughts with the community...',
                    maxLines: 6,
                    minLines: 4,
                  ),
                  const SizedBox(height: 20),

                  // Media URL
                  _TailwindLabel(label: 'Media URL (optional)'),
                  _TailwindInput(
                    controller: _mediaCtrl,
                    hint: 'Paste image/video link (e.g. YouTube, Imgur)',
                    textInputType: TextInputType.url,
                  ),
                  const SizedBox(height: 20),

                  // Attachment URL
                  _TailwindLabel(label: 'Attachment (optional)'),
                  // Kita styling mirip input file di HTML tapi fungsinya tetap text field URL
                  // karena backend logic flutter Anda menggunakan string URL
                  _TailwindInput(
                    controller: _attachmentCtrl,
                    hint: 'Paste attachment URL',
                    textInputType: TextInputType.url,
                    prefixIcon: const Icon(Icons.link, color: slate400, size: 20),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You can paste a direct link to an image or video file.',
                    style: TextStyle(fontSize: 12, color: slate400),
                  ),
                  
                  const SizedBox(height: 32), // Jarak ke tombol bawah
                ],
              ),
            ),
          ),

          // --- Footer Buttons ---
          Container(
            padding: const EdgeInsets.all(24),
            // Opsional: border top jika ingin persis seperti modal footer
            // decoration: const BoxDecoration(border: Border(top: BorderSide(color: slate200))), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // rounded-2xl
                      side: const BorderSide(color: slate200),
                    ),
                    foregroundColor: slate600,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Submit Button
                ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: slate900,
                    foregroundColor: Colors.white,
                    elevation: 2, // shadow-md
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // rounded-2xl
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Publish Post',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- Helper Widgets untuk Styling Tailwind ---

class _TailwindLabel extends StatelessWidget {
  final String label;
  const _TailwindLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14, // text-sm
          fontWeight: FontWeight.w500, // font-medium
          color: Color(0xFF475569), // text-slate-600
        ),
      ),
    );
  }
}

class _TailwindInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int minLines;
  final TextInputType? textInputType;
  final Widget? prefixIcon;

  const _TailwindInput({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.minLines = 1,
    this.textInputType,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Warna focus ring (slate-400 approximation)
    const focusColor = Color(0xFF94A3B8); 
    const bgColor = Color(0xFFF8FAFC); // slate-50
    const borderColor = Color(0xFFE2E8F0); // slate-200

    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: textInputType,
      style: const TextStyle(
        fontSize: 14, // text-sm
        color: Color(0xFF334155), // slate-700
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)), // placeholder-slate-400
        filled: true,
        fillColor: bgColor,
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // rounded-2xl
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: focusColor, width: 1.5),
        ),
      ),
    );
  }
}

class _TailwindDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _TailwindDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const focusColor = Color(0xFF94A3B8);
    const bgColor = Color(0xFFF8FAFC);
    const borderColor = Color(0xFFE2E8F0);

    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF334155), // slate-700
        fontWeight: FontWeight.normal,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: bgColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: focusColor, width: 1.5),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'EPL', child: Text('Premier League')),
        DropdownMenuItem(value: 'LALIGA', child: Text('La Liga')),
        DropdownMenuItem(value: 'SERIEA', child: Text('Serie A')),
        DropdownMenuItem(value: 'BUNDES', child: Text('Bundesliga')),
        DropdownMenuItem(value: 'LIGUE1', child: Text('Ligue 1')),
      ],
    );
  }
}