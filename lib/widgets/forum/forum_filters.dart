import 'package:flutter/material.dart';

class ForumFilters extends StatelessWidget {
  const ForumFilters({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.currentLeague,
    required this.onLeagueChanged,
    required this.currentSort,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String currentLeague;
  final ValueChanged<String> onLeagueChanged;
  final String currentSort;
  final ValueChanged<String> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 18),
                    hintText: 'Search discussions',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF94A3B8)),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionLabel(text: 'Leagues'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ForumChip(
                label: 'All',
                active: currentLeague.isEmpty,
                onTap: () => onLeagueChanged(''),
              ),
              ...const [
                ['EPL', 'Premier League'],
                ['LALIGA', 'La Liga'],
                ['SERIEA', 'Serie A'],
                ['BUNDES', 'Bundesliga'],
                ['LIGUE1', 'Ligue 1'],
              ].map(
                (e) => ForumChip(
                  label: e[1],
                  active: currentLeague == e[0],
                  onTap: () => onLeagueChanged(e[0]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _SectionLabel(text: 'Sort by'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ForumChip(
                label: 'Newest',
                active: currentSort == 'newest',
                onTap: () => onSortChanged('newest'),
              ),
              ForumChip(
                label: 'Oldest',
                active: currentSort == 'oldest',
                onTap: () => onSortChanged('oldest'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ForumChip extends StatelessWidget {
  const ForumChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? const Color(0xFF0F172A) : Colors.white,
        foregroundColor: active ? Colors.white : const Color(0xFF475569),
        side: BorderSide(
          color: active ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        elevation: active ? 6 : 0,
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}
