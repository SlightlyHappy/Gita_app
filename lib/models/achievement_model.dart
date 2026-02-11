// Achievement model and definitions for the gamification system.

class Achievement {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  Achievement copyWith({DateTime? unlockedAt}) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'emoji': emoji,
        'unlockedAt': unlockedAt?.toUtc().toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
}

/// All achievable badges.
class AchievementDefinitions {
  static List<Achievement> all() => [
        Achievement(
          id: 'first_step',
          name: 'First Step',
          description: 'Read your first verse',
          emoji: '👣',
        ),
        Achievement(
          id: 'chapter_master',
          name: 'Chapter Master',
          description: 'Complete 1 full chapter (all verses read)',
          emoji: '📖',
        ),
        Achievement(
          id: 'seeker',
          name: 'Seeker',
          description: 'Read verses from 5 different chapters',
          emoji: '🔍',
        ),
        Achievement(
          id: 'devoted_learner',
          name: 'Devoted Learner',
          description: 'Read verses from 10 chapters',
          emoji: '🙏',
        ),
        Achievement(
          id: 'wisdom_warrior',
          name: 'Wisdom Warrior',
          description: 'Read verses from 15 chapters',
          emoji: '⚔️',
        ),
        Achievement(
          id: 'complete_knowledge',
          name: 'Complete Knowledge',
          description: 'Read all 18 chapters',
          emoji: '🌟',
        ),
        Achievement(
          id: 'seven_day_sage',
          name: 'Seven Day Sage',
          description: 'Open the app 7 consecutive days',
          emoji: '🗓️',
        ),
        Achievement(
          id: 'thirty_day_saint',
          name: 'Thirty Day Saint',
          description: 'Open the app 30 consecutive days',
          emoji: '📅',
        ),
        Achievement(
          id: 'bookmark_collector',
          name: 'Bookmark Collector',
          description: 'Bookmark 10 verses',
          emoji: '📌',
        ),
        Achievement(
          id: 'shared_wisdom',
          name: 'Shared Wisdom',
          description: 'Share a verse with someone',
          emoji: '🤝',
        ),
      ];
}
