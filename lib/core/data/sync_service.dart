import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'streak_repository.dart';
import 'journal_repository.dart';
import 'badge_repository.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

class SyncService {
  final Ref _ref;
  final _supabase = Supabase.instance.client;

  SyncService(this._ref);

  Future<void> backupToCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // 1. Backup Streak
    final streak = _ref.read(streakRepositoryProvider);
    await _supabase.from('user_profiles').upsert({
      'id': user.id,
      'last_relapse': streak.lastRelapse.toIso8601String(),
      'total_relapses': streak.totalRelapses,
      'longest_streak_hours': streak.longestStreakHours,
      'updated_at': DateTime.now().toIso8601String(),
    });

    // 2. Backup Journals (JournalRepo already handles this beautifully!)
    // However, the existing method uses 'created_at'. Our table has 'timestamp'.
    // To avoid issues, we will bulk push directly here to match the exact DB schema.
    final journals = _ref.read(journalRepositoryProvider);
    final journalRows = journals.map((entry) => {
      'id': entry.id,
      'user_id': user.id,
      'mood': entry.mood,
      'note': entry.note,
      'created_at': entry.timestamp.toIso8601String(),
    }).toList();
    if (journalRows.isNotEmpty) {
      await _supabase.from('journal_entries').upsert(journalRows);
    }

    // 3. Backup Badges
    final badges = _ref.read(badgeRepositoryProvider).where((b) => b.isUnlocked).toList();
    final badgeRows = badges.map((badge) => {
      'badge_id': badge.id,
      'user_id': user.id,
      'unlocked_at': badge.unlockedAt!.toIso8601String(),
    }).toList();
    if (badgeRows.isNotEmpty) {
      await _supabase.from('user_badges').upsert(badgeRows);
    }
  }

  Future<void> restoreFromCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Currently we only implemented "Backup". 
    // Restoring requires writing directly to Hive boxes and reloading Repositories.
    // For now we fulfill the Phase 9 requirement of Backup.
    // If needed, we can implement restore here later.
    throw UnimplementedError("Restore is not fully implemented yet.");
  }
}
