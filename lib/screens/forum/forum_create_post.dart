import 'package:flutter/material.dart';

void showCreatePostModal({
  required BuildContext context,
  required String initialLeague,
  required Future<void> Function(String,String,String,String?) onSubmit,
}) {
  final title = TextEditingController();
  final content = TextEditingController();
  String league = initialLeague;
  String? mediaUrl;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: content, decoration: const InputDecoration(labelText: 'Content')),
          TextField(onChanged: (v) => mediaUrl = v, decoration: const InputDecoration(labelText: 'Media URL')),
          ElevatedButton(
            onPressed: () async {
              await onSubmit(title.text, content.text, league, mediaUrl);
              Navigator.pop(ctx);
            },
            child: const Text('Publish'),
          )
        ],
      ),
    ),
  );
}
