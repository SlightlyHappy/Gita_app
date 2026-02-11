// Models for reading session tracking and chapter progress.

class VerseReadingSession {
  final int chapterNumber;
  final int verseNumber;
  final DateTime readAt;
  final int durationSeconds;

  VerseReadingSession({
    required this.chapterNumber,
    required this.verseNumber,
    required this.readAt,
    this.durationSeconds = 5,
  });

  Map<String, dynamic> toJson() => {
        'chapterNumber': chapterNumber,
        'verseNumber': verseNumber,
        'readAt': readAt.toUtc().toIso8601String(),
        'durationSeconds': durationSeconds,
      };

  factory VerseReadingSession.fromJson(Map<String, dynamic> json) {
    return VerseReadingSession(
      chapterNumber: json['chapterNumber'] as int,
      verseNumber: json['verseNumber'] as int,
      readAt: DateTime.parse(json['readAt'] as String),
      durationSeconds: json['durationSeconds'] as int? ?? 5,
    );
  }
}

class ChapterProgress {
  final int chapterNumber;
  final Set<int> versesRead;
  int totalTimeSeconds;
  DateTime? lastReadAt;

  ChapterProgress({
    required this.chapterNumber,
    Set<int>? versesRead,
    this.totalTimeSeconds = 0,
    this.lastReadAt,
  }) : versesRead = versesRead ?? {};

  double getCompletionPercent(int totalVerses) {
    if (totalVerses <= 0) return 0.0;
    return (versesRead.length / totalVerses).clamp(0.0, 1.0);
  }

  bool isComplete(int totalVerses) => versesRead.length >= totalVerses;

  Map<String, dynamic> toJson() => {
        'chapterNumber': chapterNumber,
        'versesRead': versesRead.toList(),
        'totalTimeSeconds': totalTimeSeconds,
        'lastReadAt': lastReadAt?.toUtc().toIso8601String(),
      };

  factory ChapterProgress.fromJson(Map<String, dynamic> json) {
    return ChapterProgress(
      chapterNumber: json['chapterNumber'] as int,
      versesRead:
          (json['versesRead'] as List<dynamic>).map((e) => e as int).toSet(),
      totalTimeSeconds: json['totalTimeSeconds'] as int? ?? 0,
      lastReadAt: json['lastReadAt'] != null
          ? DateTime.parse(json['lastReadAt'] as String)
          : null,
    );
  }
}
