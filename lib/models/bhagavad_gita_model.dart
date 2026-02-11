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
  final List<WordMeaning> wordMeanings;

  Verse({
    required this.id,
    required this.chapterNumber,
    required this.verseNumber,
    required this.text,
    required this.transliteration,
    required this.meaning,
    required this.commentary,
    this.translations = const [],
    this.wordMeanings = const [],
  });

  /// Returns the preferred (primary) translation — defaults to first available.
  VerseTranslation? get preferredTranslation {
    if (translations.isEmpty) return null;
    // Prefer Swami Prabhupada
    final prabhupada = translations.firstWhere(
      (t) => t.authorName.toLowerCase().contains('prabhupada'),
      orElse: () => translations.first,
    );
    return prabhupada;
  }

  /// Returns all translations other than the preferred one.
  List<VerseTranslation> get alternativeTranslations {
    final pref = preferredTranslation;
    if (pref == null) return [];
    return translations.where((t) => t.id != pref.id).toList();
  }

  factory Verse.fromJson(Map<String, dynamic> json) {
    // Parse word_meanings — API returns a string like "word1—meaning1; word2—meaning2"
    // or sometimes a list of objects
    List<WordMeaning> parsedWordMeanings = [];
    final wm = json['word_meanings'];
    if (wm is String && wm.isNotEmpty) {
      parsedWordMeanings = WordMeaning.parseFromString(wm);
    } else if (wm is List) {
      parsedWordMeanings = wm
          .map((w) => WordMeaning.fromJson(w as Map<String, dynamic>))
          .toList();
    }

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
      wordMeanings: parsedWordMeanings,
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
      'word_meanings': wordMeanings.map((w) => w.toJson()).toList(),
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

class WordMeaning {
  final String word;
  final String meaning;
  final String? transliteration;

  WordMeaning({
    required this.word,
    required this.meaning,
    this.transliteration,
  });

  factory WordMeaning.fromJson(Map<String, dynamic> json) {
    return WordMeaning(
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      transliteration: json['transliteration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
      if (transliteration != null) 'transliteration': transliteration,
    };
  }

  /// Parse word meanings from the API's semicolon-delimited string format.
  /// Example: "śrī-bhagavān uvāca—the Supreme Personality of Godhead said; imaṁ—this"
  static List<WordMeaning> parseFromString(String raw) {
    final entries = raw.split(';');
    final results = <WordMeaning>[];
    for (final entry in entries) {
      final trimmed = entry.trim();
      if (trimmed.isEmpty) continue;
      // Try splitting by em-dash first, then regular dash
      final dashIndex = trimmed.indexOf('—');
      if (dashIndex > 0) {
        results.add(WordMeaning(
          word: trimmed.substring(0, dashIndex).trim(),
          meaning: trimmed.substring(dashIndex + 1).trim(),
        ));
      } else {
        // Fallback: treat the whole thing as a word
        results.add(WordMeaning(word: trimmed, meaning: ''));
      }
    }
    return results;
  }
}
