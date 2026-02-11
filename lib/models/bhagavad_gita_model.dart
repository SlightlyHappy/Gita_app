class Chapter {
  final int id;
  final int chapterNumber;
  final String name;
  final String transliteration;
  final String meaning;
  final int versesCount;
  final String summary;

  Chapter({
    required this.id,
    required this.chapterNumber,
    required this.name,
    required this.transliteration,
    required this.meaning,
    required this.versesCount,
    required this.summary,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] ?? 0,
      chapterNumber: json['chapter_number'] ?? 0,
      name: json['name'] ?? '',
      transliteration: json['transliteration'] ?? '',
      meaning: json['meaning'] ?? '',
      versesCount: json['verses_count'] ?? 0,
      summary: json['summary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_number': chapterNumber,
      'name': name,
      'transliteration': transliteration,
      'meaning': meaning,
      'verses_count': versesCount,
      'summary': summary,
    };
  }
}

class Verse {
  final int id;
  final int chapterNumber;
  final int verseNumber;
  final String text;
  final String transliteration;
  final String meaning;
  final String commentary;
  final List<VerseTranslation> translations;

  Verse({
    required this.id,
    required this.chapterNumber,
    required this.verseNumber,
    required this.text,
    required this.transliteration,
    required this.meaning,
    required this.commentary,
    this.translations = const [],
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'] ?? 0,
      chapterNumber: json['chapter_number'] ?? 0,
      verseNumber: json['verse_number'] ?? 0,
      text: json['text'] ?? '',
      transliteration: json['transliteration'] ?? '',
      meaning: json['meaning'] ?? '',
      commentary: json['commentary'] ?? '',
      translations: (json['translations'] as List<dynamic>?)
              ?.map((t) => VerseTranslation.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_number': chapterNumber,
      'verse_number': verseNumber,
      'text': text,
      'transliteration': transliteration,
      'meaning': meaning,
      'commentary': commentary,
      'translations': translations.map((t) => t.toJson()).toList(),
    };
  }
}

class VerseTranslation {
  final int id;
  final String description;
  final String authorName;
  final String language;

  VerseTranslation({
    required this.id,
    required this.description,
    required this.authorName,
    required this.language,
  });

  factory VerseTranslation.fromJson(Map<String, dynamic> json) {
    return VerseTranslation(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      authorName: json['author_name'] ?? '',
      language: json['language'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'author_name': authorName,
      'language': language,
    };
  }
}
