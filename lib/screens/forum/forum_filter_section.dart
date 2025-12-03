import 'package:flutter/material.dart';
import '../../widgets/forum/forum_filter_chip.dart';
import '../../widgets/forum/forum_card.dart';

class ForumFilterSection extends StatelessWidget {
  const ForumFilterSection({
    super.key,
    required this.league,
    required this.sort,
    required this.onLeagueChange,
    required this.onSortChange,
    required this.onSearch,
  });

  final String league;
  final String sort;
  final ValueChanged<String> onLeagueChange;
  final ValueChanged<String> onSortChange;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return ForumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: onSearch,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['EPL', 'LALIGA', 'SERIEA', 'BUNDES', 'LIGUE1']
                .map((e) => ForumFilterChip(
                      label: e,
                      active: league == e,
                      onTap: () => onLeagueChange(e),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              ForumFilterChip(label: 'Newest', active: sort == 'newest', onTap: () => onSortChange('newest')),
              ForumFilterChip(label: 'Oldest', active: sort == 'oldest', onTap: () => onSortChange('oldest')),
            ],
          )
        ],
      ),
    );
  }
}
