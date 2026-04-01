import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/journal_entry.dart';
import '../../core/data/journal_repository.dart';
import '../../core/data/badge_repository.dart';
import '../../core/theme/app_colors.dart';

class ComposeEntrySheet extends ConsumerStatefulWidget {
  const ComposeEntrySheet({super.key});

  @override
  ConsumerState<ComposeEntrySheet> createState() => _ComposeEntrySheetState();
}

class _ComposeEntrySheetState extends ConsumerState<ComposeEntrySheet> {
  final _noteController = TextEditingController();
  String _selectedMood = 'okay'; // default
  
  final Map<String, String> _moodEmojis = {
    'clean': '🌟',
    'okay': '⚖️',
    'urges': '🌪️',
    'relapse': '🔴',
  };

  void _submit() {
    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mood: _selectedMood,
      note: _noteController.text.trim(),
      timestamp: DateTime.now(),
    );
    ref.read(journalRepositoryProvider.notifier).addEntry(entry);
    // Evaluate journal badges
    final newCount = ref.read(journalRepositoryProvider).length + 1;
    ref.read(badgeRepositoryProvider.notifier).evaluateJournal(newCount);
    // Also evaluate urge badge if mood was 'urges'
    if (_selectedMood == 'urges') {
      ref.read(badgeRepositoryProvider.notifier).evaluateUrge();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Handles keyboard padding gracefully
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: HayaColors.surfaceCream,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          )
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content tightly
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How are you feeling?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _moodEmojis.entries.map((e) => GestureDetector(
                onTap: () => setState(() => _selectedMood = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedMood == e.key ? HayaColors.primaryTeal.withOpacity(0.1) : Colors.transparent,
                    border: Border.all(
                      color: _selectedMood == e.key ? HayaColors.primaryTeal : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(e.value, style: const TextStyle(fontSize: 36)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Reflect on your mood or any triggers...",
                hintStyle: const TextStyle(color: HayaColors.textLight),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HayaColors.primaryTeal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Reflection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
