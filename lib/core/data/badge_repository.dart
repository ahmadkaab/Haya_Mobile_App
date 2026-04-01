import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/badge_model.dart';
import '../models/streak_data.dart';
import 'streak_repository.dart';

class BadgeRepository extends StateNotifier<List<HayaBadge>> {
  final Box _box;

  BadgeRepository(this._box) : super([]) {
    _load();
  }

  void _load() {
    state = kBadgeDefinitions.map((def) {
      final saved = _box.get('badge_${def.id}') as Map<dynamic, dynamic>?;
      return HayaBadge.fromDefinition(def, saved);
    }).toList();
  }

  /// Check streak-based + optional event-based badges and unlock any newly earned.
  /// Returns list of newly unlocked badges (so UI can celebrate).
  List<HayaBadge> evaluateStreak(StreakData streak) {
    final days = streak.currentStreakDays;
    final hours = streak.currentStreakHours;

    final Map<String, bool> earned = {
      'first_hour': hours >= 1,
      'one_day': days >= 1,
      'three_days': days >= 3,
      'one_week': days >= 7,
      'two_weeks': days >= 14,
      'one_month': days >= 30,
      'three_months': days >= 90,
      'six_months': days >= 180,
      'one_year': days >= 365,
    };

    return _unlockBatch(earned);
  }

  /// Call when user completes their first or Nth journal entry.
  List<HayaBadge> evaluateJournal(int entryCount) {
    return _unlockBatch({
      'first_journal': entryCount >= 1,
      'ten_journals': entryCount >= 10,
    });
  }

  /// Call when user logs an urge.
  List<HayaBadge> evaluateUrge() {
    return _unlockBatch({'survived_urge': true});
  }

  /// Call when user completes a Dhikr session.
  List<HayaBadge> evaluateDhikr({required bool completedHundred}) {
    return _unlockBatch({
      'first_dhikr': true,
      'hundred_dhikr': completedHundred,
    });
  }

  List<HayaBadge> _unlockBatch(Map<String, bool> earned) {
    final List<HayaBadge> newlyUnlocked = [];

    final updated = state.map((badge) {
      if (badge.isUnlocked) return badge; // already unlocked — skip
      final shouldUnlock = earned[badge.id] ?? false;
      if (!shouldUnlock) return badge;

      final unlocked = badge.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      _box.put('badge_${badge.id}', unlocked.toMap());
      newlyUnlocked.add(unlocked);
      return unlocked;
    }).toList();

    if (newlyUnlocked.isNotEmpty) state = updated;
    return newlyUnlocked;
  }

  int get totalUnlocked => state.where((b) => b.isUnlocked).length;
}

final badgeBoxProvider = Provider<Box>((ref) => Hive.box('preferences'));

final badgeRepositoryProvider =
    StateNotifierProvider<BadgeRepository, List<HayaBadge>>((ref) {
  final box = ref.watch(badgeBoxProvider);
  return BadgeRepository(box);
});
