import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/bhagavad_gita_model.dart';
import '../models/reading_session_model.dart';
import '../models/achievement_model.dart';
import '../services/local_cache_service.dart';

class AppStateProvider extends ChangeNotifier {
  // ─── Theme ──────────────────────────────────────────────────────────────
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveThemePreference();
    notifyListeners();
  }

  // ─── User Profile ──────────────────────────────────────────────────────
  String _userName = '';
  String get userName => _userName;

  String _preferredLanguage = 'en';
  String get preferredLanguage => _preferredLanguage;

  TimeOfDay? _reminderTime;
  TimeOfDay? get reminderTime => _reminderTime;

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setPreferredLanguage(String lang) {
    _preferredLanguage = lang;
    notifyListeners();
  }

  void setReminderTime(TimeOfDay? time) {
    _reminderTime = time;
    notifyListeners();
  }

  // ─── First Launch / Onboarding ──────────────────────────────────────────
  bool _isFirstLaunch = true;
  bool get isFirstLaunch => _isFirstLaunch;

  Future<bool> checkAndSetFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = !(prefs.getBool('hasOnboarded') ?? false);
    notifyListeners();
    return _isFirstLaunch;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasOnboarded', true);
    _isFirstLaunch = false;
    notifyListeners();
  }

  // ─── Bookmarked Verses (formerly Favorites) ────────────────────────────
  final Set<String> _bookmarkedVerses = {};
  Set<String> get bookmarkedVerses => Set.unmodifiable(_bookmarkedVerses);

  /// Backwards-compatible alias used by existing screens.
  Set<String> get favoriteKeys => _bookmarkedVerses;

  bool isBookmarked(int chapterNumber, int verseNumber) {
    return _bookmarkedVerses.contains('$chapterNumber:$verseNumber');
  }

  /// Backwards-compatible alias.
  bool isFavorite(int chapterNumber, int verseNumber) =>
      isBookmarked(chapterNumber, verseNumber);

  void toggleBookmark(int chapterNumber, int verseNumber) {
    final key = '$chapterNumber:$verseNumber';
    if (_bookmarkedVerses.contains(key)) {
      _bookmarkedVerses.remove(key);
    } else {
      _bookmarkedVerses.add(key);
    }
    _saveBookmarkedVerses();
    _checkAchievements();
    notifyListeners();
  }

  /// Backwards-compatible alias.
  void toggleFavorite(int chapterNumber, int verseNumber) =>
      toggleBookmark(chapterNumber, verseNumber);

  // ─── Bookmarked Chapters ───────────────────────────────────────────────
  final Set<int> _bookmarkedChapters = {};
  Set<int> get bookmarkedChapters => Set.unmodifiable(_bookmarkedChapters);

  bool isChapterBookmarked(int chapterNumber) {
    return _bookmarkedChapters.contains(chapterNumber);
  }

  void toggleChapterBookmark(int chapterNumber) {
    if (_bookmarkedChapters.contains(chapterNumber)) {
      _bookmarkedChapters.remove(chapterNumber);
    } else {
      _bookmarkedChapters.add(chapterNumber);
    }
    _saveBookmarkedChapters();
    notifyListeners();
  }

  // ─── Reading Progress & Tracking ────────────────────────────────────────
  List<VerseReadingSession> _readingSessions = [];
  List<VerseReadingSession> get readingSessions =>
      List.unmodifiable(_readingSessions);

  final Map<int, ChapterProgress> _chapterProgressMap = {};
  Map<int, ChapterProgress> get chapterProgressMap =>
      Map.unmodifiable(_chapterProgressMap);

  /// Mark a verse as read. Called when the 5-second idle rule completes.
  void markVerseAsRead(int chapterNumber, int verseNumber) {
    // Skip if already read in this session
    final alreadyRead = _chapterProgressMap[chapterNumber]
            ?.versesRead
            .contains(verseNumber) ??
        false;

    final session = VerseReadingSession(
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
      readAt: DateTime.now().toUtc(),
    );
    _readingSessions.add(session);

    // Update chapter progress
    final progress = _chapterProgressMap.putIfAbsent(
        chapterNumber, () => ChapterProgress(chapterNumber: chapterNumber));
    progress.versesRead.add(verseNumber);
    progress.lastReadAt = DateTime.now().toUtc();

    // Prune sessions older than 90 days
    final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 90));
    _readingSessions.removeWhere((s) => s.readAt.isBefore(cutoff));

    _saveReadingData();
    if (!alreadyRead) {
      _checkAchievements();
    }
    notifyListeners();
  }

  /// Track time spent in a chapter.
  void addChapterTime(int chapterNumber, int seconds) {
    final progress = _chapterProgressMap.putIfAbsent(
        chapterNumber, () => ChapterProgress(chapterNumber: chapterNumber));
    progress.totalTimeSeconds += seconds;
    _saveReadingData();
    notifyListeners();
  }

  /// Get progress for a single chapter.
  double getChapterProgress(int chapterNumber, {int? totalVerses}) {
    final progress = _chapterProgressMap[chapterNumber];
    if (progress == null) return 0.0;
    if (totalVerses != null && totalVerses > 0) {
      return progress.getCompletionPercent(totalVerses);
    }
    return progress.versesRead.isNotEmpty ? 0.5 : 0.0;
  }

  /// Get number of verses read in a chapter.
  int getVersesReadCount(int chapterNumber) {
    return _chapterProgressMap[chapterNumber]?.versesRead.length ?? 0;
  }

  /// Get total reading time for a chapter (formatted).
  String getChapterTimeFormatted(int chapterNumber) {
    final secs =
        _chapterProgressMap[chapterNumber]?.totalTimeSeconds ?? 0;
    if (secs == 0) return '0m';
    final hours = secs ~/ 3600;
    final minutes = (secs % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  /// Total verses read across all chapters.
  int get totalVersesRead {
    int total = 0;
    for (final progress in _chapterProgressMap.values) {
      total += progress.versesRead.length;
    }
    return total;
  }

  /// Number of chapters that have at least one verse read.
  int get chaptersStarted => _chapterProgressMap.values
      .where((p) => p.versesRead.isNotEmpty)
      .length;

  // ─── Last Read Location ─────────────────────────────────────────────────
  final Map<int, int> _lastReadLocation = {}; // chapter → verse
  Map<int, int> get lastReadLocation => Map.unmodifiable(_lastReadLocation);

  void markLastReadLocation(int chapterNumber, int verseNumber) {
    _lastReadLocation[chapterNumber] = verseNumber;
    _saveLastReadLocation();
    notifyListeners();
  }

  int? getLastReadVerse(int chapterNumber) {
    return _lastReadLocation[chapterNumber];
  }

  // ─── Consecutive Days Tracking ──────────────────────────────────────────
  int _consecutiveDays = 0;
  int get consecutiveDays => _consecutiveDays;

  DateTime? _lastAppOpenDate;
  DateTime? get lastAppOpenDate => _lastAppOpenDate;

  /// Call on every app startup. Returns current streak.
  int trackAppOpen() {
    final today = DateTime.now().toUtc();
    if (_lastAppOpenDate == null) {
      _consecutiveDays = 1;
      _lastAppOpenDate = today;
    } else if (!_isSameDay(_lastAppOpenDate!, today)) {
      final yesterday = today.subtract(const Duration(days: 1));
      if (_isSameDay(_lastAppOpenDate!, yesterday)) {
        _consecutiveDays++;
      } else {
        _consecutiveDays = 1;
      }
      _lastAppOpenDate = today;
    }
    _saveConsecutiveDays();
    _checkAchievements();
    notifyListeners();
    return _consecutiveDays;
  }

  // ─── Share Tracking ─────────────────────────────────────────────────────
  int _shareCount = 0;
  int get shareCount => _shareCount;

  void incrementShareCount() {
    _shareCount++;
    _saveShareCount();
    _checkAchievements();
    notifyListeners();
  }

  // ─── User Journey / Legacy Progress ────────────────────────────────────
  List<DateTime> _readingHistory = [];
  List<DateTime> get readingHistory => List.unmodifiable(_readingHistory);

  int get meditationStreak => _consecutiveDays; // Use new tracking

  final Set<int> _chaptersCompleted = {};
  Set<int> get chaptersCompleted => Set.unmodifiable(_chaptersCompleted);

  Map<String, dynamic> _userAchievements = {};
  Map<String, dynamic> get userAchievements =>
      Map.unmodifiable(_userAchievements);

  void updateReadingHistory() {
    final now = DateTime.now();
    if (_readingHistory.isEmpty || !_isSameDay(_readingHistory.last, now)) {
      _readingHistory.add(now);
      _saveJourneyData();
      notifyListeners();
    }
  }

  void markChapterCompleted(int chapterNumber) {
    _chaptersCompleted.add(chapterNumber);
    _saveJourneyData();
    _checkAchievements();
    notifyListeners();
  }

  int get seekerLevel {
    final started = chaptersStarted;
    if (started >= 15) return 5;
    if (started >= 10) return 4;
    if (started >= 6) return 3;
    if (started >= 3) return 2;
    return 1;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ─── Achievement System ─────────────────────────────────────────────────
  List<Achievement> _achievements = [];
  List<Achievement> get achievements => List.unmodifiable(_achievements);

  void _initAchievements() {
    if (_achievements.isEmpty) {
      _achievements = AchievementDefinitions.all();
    }
  }

  void _checkAchievements() {
    _initAchievements();
    bool changed = false;

    for (int i = 0; i < _achievements.length; i++) {
      if (_achievements[i].isUnlocked) continue;

      bool shouldUnlock = false;
      switch (_achievements[i].id) {
        case 'first_step':
          shouldUnlock = totalVersesRead >= 1;
          break;
        case 'chapter_master':
          shouldUnlock = _chapterProgressMap.values
              .any((p) => p.versesRead.length >= 10);
          break;
        case 'seeker':
          shouldUnlock = chaptersStarted >= 5;
          break;
        case 'devoted_learner':
          shouldUnlock = chaptersStarted >= 10;
          break;
        case 'wisdom_warrior':
          shouldUnlock = chaptersStarted >= 15;
          break;
        case 'complete_knowledge':
          shouldUnlock = chaptersStarted >= 18;
          break;
        case 'seven_day_sage':
          shouldUnlock = _consecutiveDays >= 7;
          break;
        case 'thirty_day_saint':
          shouldUnlock = _consecutiveDays >= 30;
          break;
        case 'bookmark_collector':
          shouldUnlock = _bookmarkedVerses.length >= 10;
          break;
        case 'shared_wisdom':
          shouldUnlock = _shareCount >= 1;
          break;
      }

      if (shouldUnlock) {
        _achievements[i] =
            _achievements[i].copyWith(unlockedAt: DateTime.now().toUtc());
        changed = true;
      }
    }

    if (changed) {
      _saveAchievements();
    }
  }

  /// Get achievement progress as fraction [0..1].
  double getAchievementProgress(String id) {
    switch (id) {
      case 'first_step':
        return totalVersesRead >= 1 ? 1.0 : 0.0;
      case 'chapter_master':
        final maxRead = _chapterProgressMap.values.isEmpty
            ? 0
            : _chapterProgressMap.values
                .map((p) => p.versesRead.length)
                .reduce((a, b) => a > b ? a : b);
        return (maxRead / 20).clamp(0.0, 1.0);
      case 'seeker':
        return (chaptersStarted / 5).clamp(0.0, 1.0);
      case 'devoted_learner':
        return (chaptersStarted / 10).clamp(0.0, 1.0);
      case 'wisdom_warrior':
        return (chaptersStarted / 15).clamp(0.0, 1.0);
      case 'complete_knowledge':
        return (chaptersStarted / 18).clamp(0.0, 1.0);
      case 'seven_day_sage':
        return (_consecutiveDays / 7).clamp(0.0, 1.0);
      case 'thirty_day_saint':
        return (_consecutiveDays / 30).clamp(0.0, 1.0);
      case 'bookmark_collector':
        return (_bookmarkedVerses.length / 10).clamp(0.0, 1.0);
      case 'shared_wisdom':
        return _shareCount >= 1 ? 1.0 : 0.0;
      default:
        return 0.0;
    }
  }

  String getAchievementProgressLabel(String id) {
    switch (id) {
      case 'first_step':
        return '${totalVersesRead >= 1 ? 1 : 0}/1 verse';
      case 'chapter_master':
        final maxRead = _chapterProgressMap.values.isEmpty
            ? 0
            : _chapterProgressMap.values
                .map((p) => p.versesRead.length)
                .reduce((a, b) => a > b ? a : b);
        return '$maxRead verses in best chapter';
      case 'seeker':
        return '$chaptersStarted/5 chapters';
      case 'devoted_learner':
        return '$chaptersStarted/10 chapters';
      case 'wisdom_warrior':
        return '$chaptersStarted/15 chapters';
      case 'complete_knowledge':
        return '$chaptersStarted/18 chapters';
      case 'seven_day_sage':
        return '$_consecutiveDays/7 days';
      case 'thirty_day_saint':
        return '$_consecutiveDays/30 days';
      case 'bookmark_collector':
        return '${_bookmarkedVerses.length}/10 bookmarks';
      case 'shared_wisdom':
        return '$_shareCount/1 share';
      default:
        return '';
    }
  }

  // ─── Chapters Cache ─────────────────────────────────────────────────────
  List<Chapter>? _chapters;
  List<Chapter>? get chapters => _chapters;
  bool _isLoadingChapters = false;
  bool get isLoadingChapters => _isLoadingChapters;
  String? _chaptersError;
  String? get chaptersError => _chaptersError;

  Future<void> loadChapters() async {
    if (_chapters != null) return;
    _isLoadingChapters = true;
    _chaptersError = null;
    notifyListeners();

    try {
      _chapters = await LocalCacheService.instance.loadChapters();
      _chaptersError = null;
    } catch (e) {
      _chaptersError = e.toString();
    }

    _isLoadingChapters = false;
    notifyListeners();
  }

  // ─── Notification Settings ──────────────────────────────────────────────
  bool _dailyQuotesEnabled = true;
  bool get dailyQuotesEnabled => _dailyQuotesEnabled;

  int _notificationHour = 6;
  int get notificationHour => _notificationHour;

  int _notificationMinute = 30;
  int get notificationMinute => _notificationMinute;

  bool _isAM = true;
  bool get isAM => _isAM;

  void toggleDailyQuotes() {
    _dailyQuotesEnabled = !_dailyQuotesEnabled;
    _saveNotificationSettings();
    notifyListeners();
  }

  void setNotificationTime(int hour, int minute, bool isAM) {
    _notificationHour = hour;
    _notificationMinute = minute;
    _isAM = isAM;
    _saveNotificationSettings();
    notifyListeners();
  }

  /// Convert 12-hour to 24-hour format.
  int get notification24Hour {
    int h = _notificationHour;
    if (_isAM) {
      if (h == 12) h = 0;
    } else {
      if (h != 12) h += 12;
    }
    return h;
  }

  // ─── Font Size ──────────────────────────────────────────────────────────
  double _fontSize = 18;
  double get fontSize => _fontSize;

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  // ─── Theme Intensity ────────────────────────────────────────────────────
  double _themeIntensity = 75;
  double get themeIntensity => _themeIntensity;

  void setThemeIntensity(double intensity) {
    _themeIntensity = intensity;
    notifyListeners();
  }

  // ─── Persistence ────────────────────────────────────────────────────────
  Future<void> init() async {
    await _loadBookmarkedVerses();
    await _loadThemePreference();
    await _loadUserProfile();
    await _loadBookmarkedChapters();
    await _loadJourneyData();
    await _loadReadingData();
    await _loadLastReadLocation();
    await _loadConsecutiveDays();
    await _loadShareCount();
    await _loadAchievements();
    await _loadNotificationSettings();
    await checkAndSetFirstLaunch();
    _initAchievements();
    _mergeAchievements();
    trackAppOpen();
  }

  // ── Bookmarked Verses Persistence ──

  Future<void> _loadBookmarkedVerses() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favorites') ?? [];
    _bookmarkedVerses.addAll(saved);
    notifyListeners();
  }

  Future<void> _saveBookmarkedVerses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _bookmarkedVerses.toList());
  }

  // ── Theme Persistence ──

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  // ── User Profile Persistence ──

  Future<void> saveUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName);
    await prefs.setString('preferredLanguage', _preferredLanguage);
    if (_reminderTime != null) {
      await prefs.setInt('reminderHour', _reminderTime!.hour);
      await prefs.setInt('reminderMinute', _reminderTime!.minute);
    }
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? '';
    _preferredLanguage = prefs.getString('preferredLanguage') ?? 'en';
    final hour = prefs.getInt('reminderHour');
    final minute = prefs.getInt('reminderMinute');
    if (hour != null && minute != null) {
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    }
  }

  // ── Bookmarked Chapters Persistence ──

  Future<void> _saveBookmarkedChapters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'bookmarkedChapters',
      _bookmarkedChapters.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _loadBookmarkedChapters() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('bookmarkedChapters') ?? [];
    _bookmarkedChapters.addAll(saved.map((e) => int.parse(e)));
  }

  // ── Reading Data Persistence ──

  Future<void> _saveReadingData() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson =
        jsonEncode(_readingSessions.map((s) => s.toJson()).toList());
    await prefs.setString('readingSessions', sessionsJson);

    final progressJson = jsonEncode(
        _chapterProgressMap.map((k, v) => MapEntry(k.toString(), v.toJson())));
    await prefs.setString('chapterProgressMap', progressJson);
  }

  Future<void> _loadReadingData() async {
    final prefs = await SharedPreferences.getInstance();

    final sessionsStr = prefs.getString('readingSessions');
    if (sessionsStr != null) {
      try {
        final List<dynamic> data = jsonDecode(sessionsStr);
        _readingSessions = data
            .map((e) =>
                VerseReadingSession.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    final progressStr = prefs.getString('chapterProgressMap');
    if (progressStr != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(progressStr);
        data.forEach((key, value) {
          _chapterProgressMap[int.parse(key)] =
              ChapterProgress.fromJson(value as Map<String, dynamic>);
        });
      } catch (_) {}
    }
  }

  // ── Last Read Location Persistence ──

  Future<void> _saveLastReadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(
        _lastReadLocation.map((k, v) => MapEntry(k.toString(), v)));
    await prefs.setString('lastReadLocation', json);
  }

  Future<void> _loadLastReadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('lastReadLocation');
    if (str != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(str);
        data.forEach((key, value) {
          _lastReadLocation[int.parse(key)] = value as int;
        });
      } catch (_) {}
    }
  }

  // ── Consecutive Days Persistence ──

  Future<void> _saveConsecutiveDays() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('consecutiveDays', _consecutiveDays);
    if (_lastAppOpenDate != null) {
      await prefs.setString(
          'lastAppOpenDate', _lastAppOpenDate!.toIso8601String());
    }
  }

  Future<void> _loadConsecutiveDays() async {
    final prefs = await SharedPreferences.getInstance();
    _consecutiveDays = prefs.getInt('consecutiveDays') ?? 0;
    final dateStr = prefs.getString('lastAppOpenDate');
    if (dateStr != null) {
      _lastAppOpenDate = DateTime.parse(dateStr);
    }
  }

  // ── Share Count Persistence ──

  Future<void> _saveShareCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shareCount', _shareCount);
  }

  Future<void> _loadShareCount() async {
    final prefs = await SharedPreferences.getInstance();
    _shareCount = prefs.getInt('shareCount') ?? 0;
  }

  // ── Achievement Persistence ──

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final json =
        jsonEncode(_achievements.map((a) => a.toJson()).toList());
    await prefs.setString('achievements_v2', json);
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('achievements_v2');
    if (str != null) {
      try {
        final List<dynamic> data = jsonDecode(str);
        _achievements = data
            .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _achievements = [];
      }
    }
  }

  /// Merge loaded achievements with definitions (in case new ones were added).
  void _mergeAchievements() {
    final defs = AchievementDefinitions.all();
    final loadedMap = {for (final a in _achievements) a.id: a};

    _achievements = defs.map((def) {
      final existing = loadedMap[def.id];
      if (existing != null && existing.isUnlocked) {
        return def.copyWith(unlockedAt: existing.unlockedAt);
      }
      return def;
    }).toList();
  }

  // ── Notification Settings Persistence ──

  Future<void> _saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyQuotesEnabled', _dailyQuotesEnabled);
    await prefs.setInt('settingsNotifHour', _notificationHour);
    await prefs.setInt('settingsNotifMinute', _notificationMinute);
    await prefs.setBool('settingsNotifIsAM', _isAM);
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyQuotesEnabled = prefs.getBool('dailyQuotesEnabled') ?? true;
    _notificationHour = prefs.getInt('settingsNotifHour') ?? 6;
    _notificationMinute = prefs.getInt('settingsNotifMinute') ?? 30;
    _isAM = prefs.getBool('settingsNotifIsAM') ?? true;
  }

  // ── Journey Data Persistence (legacy) ──

  Future<void> _saveJourneyData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'chaptersCompleted',
      _chaptersCompleted.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      'readingHistory',
      _readingHistory.map((e) => e.toIso8601String()).toList(),
    );
    await prefs.setString(
      'userAchievements',
      jsonEncode(_userAchievements),
    );
  }

  Future<void> _loadJourneyData() async {
    final prefs = await SharedPreferences.getInstance();
    final completedStr = prefs.getStringList('chaptersCompleted') ?? [];
    _chaptersCompleted.addAll(completedStr.map((e) => int.parse(e)));

    final historyStr = prefs.getStringList('readingHistory') ?? [];
    _readingHistory = historyStr.map((e) => DateTime.parse(e)).toList();

    final achievementsStr = prefs.getString('userAchievements');
    if (achievementsStr != null) {
      _userAchievements =
          jsonDecode(achievementsStr) as Map<String, dynamic>;
    }
  }
}
