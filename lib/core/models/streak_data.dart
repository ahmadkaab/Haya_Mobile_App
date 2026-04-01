class StreakData {
  final DateTime lastRelapse;
  final int totalRelapses;
  final int longestStreakHours;

  const StreakData({
    required this.lastRelapse,
    required this.totalRelapses,
    required this.longestStreakHours,
  });

  factory StreakData.fromMap(Map<dynamic, dynamic> map) {
    return StreakData(
      lastRelapse: DateTime.fromMillisecondsSinceEpoch(map['lastRelapse'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      totalRelapses: map['totalRelapses'] as int? ?? 0,
      longestStreakHours: map['longestStreakHours'] as int? ?? 0,
    );
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'lastRelapse': lastRelapse.millisecondsSinceEpoch,
      'totalRelapses': totalRelapses,
      'longestStreakHours': longestStreakHours,
    };
  }

  // Helper calculating live streak data
  int get currentStreakHours => DateTime.now().difference(lastRelapse).inHours;
  int get currentStreakDays => DateTime.now().difference(lastRelapse).inDays;

  // Render logic string for UI: "X Days" or "X Hours"
  String get displayString {
    final diff = DateTime.now().difference(lastRelapse);
    if (diff.inDays > 0) {
      if (diff.inDays == 1) return "1 Day";
      return "${diff.inDays} Days";
    } else {
      if (diff.inHours == 1) return "1 Hour";
      if (diff.inHours == 0) return "Just Now";
      return "${diff.inHours} Hours";
    }
  }

  StreakData copyWith({
    DateTime? lastRelapse,
    int? totalRelapses,
    int? longestStreakHours,
  }) {
    return StreakData(
      lastRelapse: lastRelapse ?? this.lastRelapse,
      totalRelapses: totalRelapses ?? this.totalRelapses,
      longestStreakHours: longestStreakHours ?? this.longestStreakHours,
    );
  }
}
