import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/journal_entry.dart';

class JournalRepository extends StateNotifier<List<JournalEntry>> {
  final Box _box;
  // Read user directly from Supabase auth — avoids storing a stale Ref
  User? get _user => Supabase.instance.client.auth.currentUser;
  final _supabase = Supabase.instance.client;

  JournalRepository(this._box) : super([]) {
    _loadEntries();
  }

  void _loadEntries() {
    final rawEntries = _box.values.toList();
    final entries = rawEntries
        .map((e) => JournalEntry.fromMap(e as Map))
        .toList();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = entries;
  }

  Future<void> addEntry(JournalEntry entry) async {
    // 1. Always save locally first (offline-first)
    await _box.put(entry.id, entry.toMap());
    state = [entry, ...state];

    // 2. Mirror to cloud if authenticated
    if (_user != null) {
      try {
        await _supabase.from('journal_entries').upsert({
          'id': entry.id,
          'user_id': _user!.id,
          'mood': entry.mood,
          'note': entry.note,
          'created_at': entry.timestamp.toIso8601String(),
        });
      } catch (_) {
        // Cloud sync failed silently — local data is still safe
      }
    }
  }

  Future<void> deleteEntry(String id) async {
    // 1. Delete locally
    await _box.delete(id);
    state = state.where((entry) => entry.id != id).toList();

    // 2. Mirror deletion to cloud if authenticated
    if (_user != null) {
      try {
        await _supabase
            .from('journal_entries')
            .delete()
            .eq('id', id)
            .eq('user_id', _user!.id);
      } catch (_) {
        // Ignore — local deletion already succeeded
      }
    }
  }

  /// Pull all cloud entries and merge into local Hive. Returns count of new entries pulled.
  Future<int> syncFromCloud() async {
    if (_user == null) return 0;
    try {
      final response = await _supabase
          .from('journal_entries')
          .select()
          .eq('user_id', _user!.id)
          .order('created_at', ascending: false) as List;

      int newCount = 0;
      for (final row in response) {
        final id = row['id'] as String;
        if (!_box.containsKey(id)) {
          final entry = JournalEntry(
            id: id,
            mood: row['mood'] as String,
            note: row['note'] as String,
            timestamp: DateTime.parse(row['created_at'] as String),
          );
          await _box.put(id, entry.toMap());
          newCount++;
        }
      }
      if (newCount > 0) _loadEntries();
      return newCount;
    } catch (_) {
      return 0;
    }
  }

  /// Push all local entries to cloud via upsert (safe to call multiple times).
  Future<void> pushLocalToCloud() async {
    if (_user == null) return;
    final rows = state.map((entry) => {
      'id': entry.id,
      'user_id': _user!.id,
      'mood': entry.mood,
      'note': entry.note,
      'created_at': entry.timestamp.toIso8601String(),
    }).toList();

    if (rows.isEmpty) return;
    try {
      await _supabase.from('journal_entries').upsert(rows);
    } catch (_) {
      // Silently fail — user data is safe locally
    }
  }
}

final journalBoxProvider = Provider<Box>((ref) => Hive.box('journal'));

final journalRepositoryProvider =
    StateNotifierProvider<JournalRepository, List<JournalEntry>>((ref) {
  final box = ref.watch(journalBoxProvider);
  return JournalRepository(box);
});
