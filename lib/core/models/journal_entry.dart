class JournalEntry {
  final String id;
  final String mood; // 'great', 'okay', 'heavy_urges', 'relapsed'
  final String note;
  final DateTime timestamp;

  JournalEntry({
    required this.id,
    required this.mood,
    required this.note,
    required this.timestamp,
  });

  factory JournalEntry.fromMap(Map<dynamic, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      mood: map['mood'] as String,
      note: map['note'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood': mood,
      'note': note,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
