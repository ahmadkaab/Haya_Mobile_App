import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/data/journal_repository.dart';
import '../../core/theme/app_colors.dart';
import 'compose_entry_sheet.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  final Map<String, String> _moodMap = const {
    'clean': '🌟 Great',
    'okay': '⚖️ Okay',
    'urges': '🌪️ Urges',
    'relapse': '🔴 Relapse',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalRepositoryProvider);

    return Scaffold(
      backgroundColor: HayaColors.primaryCream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 32.0, bottom: 16.0),
              child: Text(
                'Your Journey',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: HayaColors.textDark,
                ),
              ),
            ),
            Expanded(
              child: entries.isEmpty 
                ? const Center(
                    child: Text(
                      "Your reflections will appear here.",
                      style: TextStyle(color: HayaColors.textLight, fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _moodMap[entry.mood] ?? entry.mood,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  DateFormat('MMM d, h:mm a').format(entry.timestamp),
                                  style: const TextStyle(color: HayaColors.textLight, fontSize: 14),
                                ),
                              ],
                            ),
                            if (entry.note.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                entry.note,
                                style: const TextStyle(color: HayaColors.textDark, height: 1.5, fontSize: 15),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const ComposeEntrySheet(),
          );
        },
        backgroundColor: HayaColors.primaryTeal,
        elevation: 4,
        child: const Icon(LucideIcons.penSquare, color: Colors.white),
      ),
    );
  }
}
