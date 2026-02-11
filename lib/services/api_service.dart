import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/bhagavad_gita_model.dart';

class ApiService {
  // Bhagavad Gita API via RapidAPI
  static const String baseUrl = 'https://bhagavad-gita3.p.rapidapi.com';
  static const String apiHost = 'bhagavad-gita3.p.rapidapi.com';
  static const String apiKey = '384db0f76cmsh7507969c4885b21p1d27eejsnd9f7200afc2b';
  
  /// Default headers for all requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-rapidapi-key': apiKey,
    'x-rapidapi-host': apiHost,
  };
  
  /// Fetch all chapters
  static Future<List<Chapter>> fetchChapters() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v2/chapters/?skip=0&limit=18'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Chapter.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load chapters: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching chapters: $e');
    }
  }

  /// Fetch verses for a specific chapter
  static Future<List<Verse>> fetchVerses(int chapterNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v2/chapters/$chapterNumber/verses/?skip=0&limit=200'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        
        // API returns array of verse objects, each with nested translations
        List<Verse> verses = [];
        
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            // Get English translation if available
            final translationsData = item['translations'] as List<dynamic>? ?? [];
            final translationList = translationsData
                .map((t) => VerseTranslation.fromJson(t as Map<String, dynamic>))
                .toList();
            
            final english = translationList.firstWhere(
              (t) => t.language == 'english',
              orElse: () => VerseTranslation(id: 0, description: '', authorName: '', language: ''),
            );
            
            verses.add(Verse(
              id: item['id'] as int? ?? 0,
              chapterNumber: item['chapter_number'] as int? ?? chapterNumber,
              verseNumber: item['verse_number'] as int? ?? 0,
              text: item['text'] as String? ?? '',
              transliteration: item['transliteration'] as String? ?? '',
              meaning: english.description,
              commentary: '',
              translations: translationList,
            ));
          }
        }
        
        return verses;
      } else {
        throw Exception('Failed to load verses: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching verses: $e');
    }
  }

  /// Fetch a specific verse
  static Future<Verse> fetchVerse(int chapterNumber, int verseNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v2/chapters/$chapterNumber/verses/$verseNumber/'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // API returns: {id, text, transliteration, word_meanings, translations: [...], commentaries: [...]}
        final List<dynamic> translationsData = data['translations'] as List<dynamic>? ?? [];
        
        // Create VerseTranslation objects from nested translations array
        final translationList = translationsData
            .map((t) => VerseTranslation.fromJson(t as Map<String, dynamic>))
            .toList();
        
        // Use main verse text and transliteration from top-level fields
        final text = data['text'] as String? ?? '';
        final transliteration = data['transliteration'] as String? ?? '';
        
        // Find English meaning from translations
        final english = translationList.firstWhere(
          (t) => t.language == 'english',
          orElse: () => VerseTranslation(
            id: 0,
            description: '',
            authorName: '',
            language: '',
          ),
        );
        
        return Verse(
          id: data['id'] as int? ?? 0,
          chapterNumber: data['chapter_number'] as int? ?? chapterNumber,
          verseNumber: data['verse_number'] as int? ?? verseNumber,
          text: text,
          transliteration: transliteration,
          meaning: english.description,
          commentary: '',
          translations: translationList,
        );
      } else {
        throw Exception('Failed to load verse: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching verse: $e');
    }
  }
}
