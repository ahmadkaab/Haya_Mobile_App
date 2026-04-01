enum BadgeCategory { streak, resilience, spiritual, milestone }

class HayaBadge {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final BadgeCategory category;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const HayaBadge({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.category,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  HayaBadge copyWith({bool? isUnlocked, DateTime? unlockedAt}) {
    return HayaBadge(
      id: id,
      emoji: emoji,
      title: title,
      description: description,
      category: category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
      };

  factory HayaBadge.fromDefinition(HayaBadge def, Map<dynamic, dynamic>? saved) {
    if (saved == null) return def;
    return def.copyWith(
      isUnlocked: saved['isUnlocked'] as bool? ?? false,
      unlockedAt: saved['unlockedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(saved['unlockedAt'] as int)
          : null,
    );
  }
}

/// All badge definitions — single source of truth.
const List<HayaBadge> kBadgeDefinitions = [
  // ── Streak Badges ──────────────────────────────────────────────────────────
  HayaBadge(
    id: 'first_hour',
    emoji: '🌱',
    title: 'First Step',
    description: 'Survived your first hour clean',
    category: BadgeCategory.streak,
  ),
  HayaBadge(
    id: 'one_day',
    emoji: '🌤️',
    title: 'One Day Strong',
    description: 'Completed 24 hours clean',
    category: BadgeCategory.streak,
  ),
  HayaBadge(
    id: 'three_days',
    emoji: '⚔️',
    title: '3-Day Warrior',
    description: 'Three days of victory',
    category: BadgeCategory.streak,
  ),
  HayaBadge(
    id: 'one_week',
    emoji: '🌙',
    title: 'Week of Purity',
    description: 'A full week clean — like Laylatul Qadr energy',
    category: BadgeCategory.streak,
  ),
  HayaBadge(
    id: 'two_weeks',
    emoji: '💫',
    title: 'Fortnight Fighter',
    description: 'Two solid weeks of discipline',
    category: BadgeCategory.streak,
  ),
  HayaBadge(
    id: 'one_month',
    emoji: '🏅',
    title: '30-Day Champion',
    description: 'A full month of clarity and purity',
    category: BadgeCategory.streak,
  ),
  HayaBadge(
    id: 'three_months',
    emoji: '🌟',
    title: 'Ramadan Spirit',
    description: '90 days — the discipline of a whole blessed month',
    category: BadgeCategory.streak,
  ),
  HayaBadge(
    id: 'six_months',
    emoji: '🦁',
    title: 'Mujahid',
    description: '6 months of inner jihad and victory',
    category: BadgeCategory.streak,
  ),
  HayaBadge(
    id: 'one_year',
    emoji: '👑',
    title: 'Crown of Purity',
    description: '365 days — a full year clean. May Allah accept.',
    category: BadgeCategory.streak,
  ),

  // ── Spiritual Badges ───────────────────────────────────────────────────────
  HayaBadge(
    id: 'first_dhikr',
    emoji: '📿',
    title: 'First Remembrance',
    description: 'Completed your first Dhikr session',
    category: BadgeCategory.spiritual,
  ),
  HayaBadge(
    id: 'hundred_dhikr',
    emoji: '✨',
    title: 'MashaAllah 100',
    description: 'Completed the full 100 Dhikr cycle',
    category: BadgeCategory.spiritual,
  ),
  HayaBadge(
    id: 'seven_dhikr_days',
    emoji: '🕌',
    title: 'Consistent Worshipper',
    description: 'Did Dhikr for 7 days in a row',
    category: BadgeCategory.spiritual,
  ),

  // ── Resilience Badges ──────────────────────────────────────────────────────
  HayaBadge(
    id: 'first_journal',
    emoji: '📖',
    title: 'Self-Aware',
    description: 'Wrote your first journal entry',
    category: BadgeCategory.resilience,
  ),
  HayaBadge(
    id: 'ten_journals',
    emoji: '🖊️',
    title: 'Dedicated Writer',
    description: 'Logged 10 journal entries',
    category: BadgeCategory.resilience,
  ),
  HayaBadge(
    id: 'survived_urge',
    emoji: '🛡️',
    title: 'Urge Survivor',
    description: 'Logged an urge and resisted it',
    category: BadgeCategory.resilience,
  ),
];
