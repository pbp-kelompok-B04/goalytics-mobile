import 'package:flutter/material.dart';

class ForumSelectField extends StatelessWidget {
  const ForumSelectField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(labelText: 'League'),
      items: const [
        DropdownMenuItem(value: 'EPL', child: Text('Premier League')),
        DropdownMenuItem(value: 'LALIGA', child: Text('La Liga')),
        DropdownMenuItem(value: 'SERIEA', child: Text('Serie A')),
        DropdownMenuItem(value: 'BUNDES', child: Text('Bundesliga')),
        DropdownMenuItem(value: 'LIGUE1', child: Text('Ligue 1')),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
