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

  // Palet Warna Tailwind Slate
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate900 = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24), // p-6
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // rounded-3xl
        border: Border.all(color: slate200), // border-slate-200
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000), // shadow-sm (lebih halus)
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Search Bar ---
          // flex flex-col gap-3 ...
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: const TextStyle(fontSize: 14, color: slate600),
            decoration: InputDecoration(
              hintText: 'Search discussions',
              hintStyle: const TextStyle(color: slate600),
              filled: true,
              fillColor: slate50, // bg-slate-50
              prefixIcon: const Icon(Icons.search, size: 20, color: slate400),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14, // py-3
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16), // rounded-2xl
                borderSide: const BorderSide(color: slate200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: slate400),
              ),
            ),
          ),

          const SizedBox(height: 24), // gap-6

          // --- Leagues Section ---
          const _SectionLabel(text: 'Leagues'),
          const SizedBox(height: 8), // mb-2
          Wrap(
            spacing: 8, // gap-2
            runSpacing: 8,
            children: [
              _ForumChip(
                label: 'All',
                isActive: currentLeague.isEmpty,
                onTap: () => onLeagueChanged(''),
              ),
              ...const [
                ['EPL', 'Premier League'],
                ['LALIGA', 'La Liga'],
                ['SERIEA', 'Serie A'],
                ['BUNDES', 'Bundesliga'],
                ['LIGUE1', 'Ligue 1'],
              ].map(
                (e) => _ForumChip(
                  label: e[1],
                  isActive: currentLeague == e[0],
                  onTap: () => onLeagueChanged(e[0]),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16), // space-y-4 (jarak antar section)

          // --- Sort Section ---
          const _SectionLabel(text: 'Sort by'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ForumChip(
                label: 'Newest',
                isActive: currentSort == 'newest',
                onTap: () => onSortChanged('newest'),
              ),
              _ForumChip(
                label: 'Oldest',
                isActive: currentSort == 'oldest',
                onTap: () => onSortChanged('oldest'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ForumChip extends StatelessWidget {
  const _ForumChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Style Mapping:
    // Active: bg-slate-900 text-white shadow-xl border-slate-900
    // Inactive: bg-white text-slate-600 border-slate-200
    
    const slate200 = Color(0xFFE2E8F0);
    const slate600 = Color(0xFF475569);
    const slate900 = Color(0xFF0F172A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // px-4 py-2
        decoration: BoxDecoration(
          color: isActive ? slate900 : Colors.white,
          borderRadius: BorderRadius.circular(16), // rounded-2xl
          border: Border.all(
            color: isActive ? slate900 : slate200,
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  const BoxShadow(
                    color: Color(0x330F172A), // shadow-xl approximation
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14, // text-sm
            fontWeight: FontWeight.w500, // font-medium
            color: isActive ? Colors.white : slate600,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    // text-xs font-medium uppercase tracking-wide text-slate-400
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12, // text-xs
        fontWeight: FontWeight.w600, // font-medium (sedikit lebih tebal agar terbaca)
        letterSpacing: 0.8, // tracking-wide
        color: Color(0xFF94A3B8), // text-slate-400
      ),
    );
  }
}