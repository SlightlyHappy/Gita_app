import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bhagavad_gita_model.dart';
import '../services/api_service.dart';

/// Local caching service for chapters and verses.
/// Uses SharedPreferences for lightweight JSON storage.
class LocalCacheService {
  LocalCacheService._();
  static final LocalCacheService instance = LocalCacheService._();

  static const String _chaptersKey = 'cached_chapters';
  static const String _chaptersCacheTimeKey = 'chapters_cache_time';
  static const String _versesKeyPrefix = 'cached_verses_ch_';
  static const String _versesCacheTimePrefix = 'verses_cache_time_ch_';

  /// Max cache age before refresh (24 hours).
  static const Duration _maxCacheAge = Duration(hours: 24);

  // ─── Chapters ───────────────────────────────────────────────────────────

  /// Load chapters: try cache first, then API.
  Future<List<Chapter>> loadChapters({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _getCachedChapters();
      if (cached != null) return cached;
    }
    // Fetch from API and cache
    try {
      final chapters = await ApiService.fetchChapters();
      await _cacheChapters(chapters);
      return chapters;
    } catch (e) {
      // On error, try returning stale cache
      final stale = await _getCachedChapters(ignoreAge: true);
      if (stale != null) return stale;
      rethrow;
    }
  }

  Future<List<Chapter>?> _getCachedChapters({bool ignoreAge = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_chaptersKey);
    if (cachedJson == null) return null;

    if (!ignoreAge) {
      final cacheTime = prefs.getInt(_chaptersCacheTimeKey) ?? 0;
      final elapsed =
          DateTime.now().millisecondsSinceEpoch - cacheTime;
      if (elapsed > _maxCacheAge.inMilliseconds) return null;
    }

    try {
      final List<dynamic> data = jsonDecode(cachedJson);
      return data
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheChapters(List<Chapter> chapters) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(chapters.map((c) => c.toJson()).toList());
    await prefs.setString(_chaptersKey, json);
    await prefs.setInt(
        _chaptersCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  // ─── Verses ─────────────────────────────────────────────────────────────

  /// Load verses for a chapter: try cache first, then API.
  Future<List<Verse>> loadVerses(int chapterNumber,
      {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _getCachedVerses(chapterNumber);
      if (cached != null) return cached;
    }
    try {
      final verses = await ApiService.fetchVerses(chapterNumber);
      await _cacheVerses(chapterNumber, verses);
      return verses;
    } catch (e) {
      final stale =
          await _getCachedVerses(chapterNumber, ignoreAge: true);
      if (stale != null) return stale;
      rethrow;
    }
  }

  Future<List<Verse>?> _getCachedVerses(int chapterNumber,
      {bool ignoreAge = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_versesKeyPrefix$chapterNumber';
    final cachedJson = prefs.getString(key);
    if (cachedJson == null) return null;

    if (!ignoreAge) {
      final timeKey = '$_versesCacheTimePrefix$chapterNumber';
      final cacheTime = prefs.getInt(timeKey) ?? 0;
      final elapsed =
          DateTime.now().millisecondsSinceEpoch - cacheTime;
      if (elapsed > _maxCacheAge.inMilliseconds) return null;
    }

    try {
      final List<dynamic> data = jsonDecode(cachedJson);
      return data
          .map((e) => Verse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheVerses(
      int chapterNumber, List<Verse> verses) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_versesKeyPrefix$chapterNumber';
    final timeKey = '$_versesCacheTimePrefix$chapterNumber';
    final json = jsonEncode(verses.map((v) => v.toJson()).toList());
    await prefs.setString(key, json);
    await prefs.setInt(timeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear all caches.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaptersKey);
    await prefs.remove(_chaptersCacheTimeKey);
    // Remove all verses caches
    for (int i = 1; i <= 18; i++) {
      await prefs.remove('$_versesKeyPrefix$i');
      await prefs.remove('$_versesCacheTimePrefix$i');
    }
  }
}
