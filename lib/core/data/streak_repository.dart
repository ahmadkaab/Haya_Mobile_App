import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/streak_data.dart';

class StreakRepository extends StateNotifier<StreakData> {
  final Box _box;

  StreakRepository(this._box) : super(StreakData(lastRelapse: DateTime.now(), totalRelapses: 0, longestStreakHours: 0)) {
    _loadData();
  }

  void _loadData() {
    final rawData = _box.get('streak_data');
    if (rawData != null) {
      state = StreakData.fromMap(rawData as Map);
    } else {
      // Initialize if first time booting app
      final initial = StreakData(
        lastRelapse: DateTime.now(),
        totalRelapses: 0,
        longestStreakHours: 0,
      );
      _box.put('streak_data', initial.toMap());
      state = initial;
    }
  }

  Future<void> relapse() async {
    // 1. Calculate how long they survived
    final currentStreak = state.currentStreakHours;
    final newLongest = currentStreak > state.longestStreakHours ? currentStreak : state.longestStreakHours;

    // 2. Create the punishing new state (resets clock, +1 relapse total)
    final newState = StreakData(
      lastRelapse: DateTime.now(),
      totalRelapses: state.totalRelapses + 1,
      longestStreakHours: newLongest,
    );

    // 3. Save permanently to Hive and push to Riverpod UI listeners instantly
    await _box.put('streak_data', newState.toMap());
    state = newState;
  }

  Future<void> clearAllData() async {
     final resetState = StreakData(lastRelapse: DateTime.now(), totalRelapses: 0, longestStreakHours: 0);
     await _box.put('streak_data', resetState.toMap());
     // Also clear journals
     await Hive.box('journal').clear();
     state = resetState;
  }
}

final preferencesBoxProvider = Provider<Box>((ref) => Hive.box('preferences'));

final streakRepositoryProvider = StateNotifierProvider<StreakRepository, StreakData>((ref) {
  final box = ref.watch(preferencesBoxProvider);
  return StreakRepository(box);
});
