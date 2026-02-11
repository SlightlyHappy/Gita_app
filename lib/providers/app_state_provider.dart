import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/bhagavad_gita_model.dart';
import '../services/api_service.dart';

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

  // ─── Favorites ──────────────────────────────────────────────────────────
  final Set<String> _favoriteKeys = {};
  Set<String> get favoriteKeys => Set.unmodifiable(_favoriteKeys);

  bool isFavorite(int chapterNumber, int verseNumber) {
    return _favoriteKeys.contains('$chapterNumber:$verseNumber');
  }

  void toggleFavorite(int chapterNumber, int verseNumber) {
    final key = '$chapterNumber:$verseNumber';
    if (_favoriteKeys.contains(key)) {
      _favoriteKeys.remove(key);
    } else {
      _favoriteKeys.add(key);
    }
    _saveFavorites();
    notifyListeners();
  }

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

  // ─── User Journey / Progress ────────────────────────────────────────────
  List<DateTime> _readingHistory = [];
  List<DateTime> get readingHistory => List.unmodifiable(_readingHistory);

  int _meditationStreak = 0;
  int get meditationStreak => _meditationStreak;

  final Set<int> _chaptersCompleted = {};
  Set<int> get chaptersCompleted => Set.unmodifiable(_chaptersCompleted);

  Map<String, dynamic> _userAchievements = {};
  Map<String, dynamic> get userAchievements =>
      Map.unmodifiable(_userAchievements);

  void updateReadingHistory() {
    final now = DateTime.now();
    // Only add if last entry wasn't today
    if (_readingHistory.isEmpty ||
        !_isSameDay(_readingHistory.last, now)) {
      _readingHistory.add(now);
      _saveJourneyData();
      notifyListeners();
    }
  }

  void updateMeditationStreak() {
    final now = DateTime.now();
    if (_readingHistory.isNotEmpty &&
        _isSameDay(_readingHistory.last, now)) {
      // Already counted today
      return;
    }
    if (_readingHistory.isNotEmpty) {
      final yesterday = now.subtract(const Duration(days: 1));
      if (_isSameDay(_readingHistory.last, yesterday)) {
        _meditationStreak++;
      } else {
        _meditationStreak = 1;
      }
    } else {
      _meditationStreak = 1;
    }
    _saveJourneyData();
    notifyListeners();
  }

  void markChapterCompleted(int chapterNumber) {
    _chaptersCompleted.add(chapterNumber);
    // Check achievements
    if (_chaptersCompleted.length == 1) {
      _userAchievements['first_chapter'] = {
        'name': 'First Chapter',
        'date': DateTime.now().toIso8601String(),
      };
    }
    if (_chaptersCompleted.length >= 5) {
      _userAchievements['five_chapters'] = {
        'name': 'Dedicated Seeker',
        'date': DateTime.now().toIso8601String(),
      };
    }
    if (_chaptersCompleted.length >= 18) {
      _userAchievements['all_chapters'] = {
        'name': 'Enlightened One',
        'date': DateTime.now().toIso8601String(),
      };
    }
    _saveJourneyData();
    notifyListeners();
  }

  double getChapterProgress(int chapterNumber) {
    if (_chaptersCompleted.contains(chapterNumber)) return 1.0;
    // Could be extended with verse-level tracking
    return 0.0;
  }

  int get seekerLevel {
    final completed = _chaptersCompleted.length;
    if (completed >= 15) return 5;
    if (completed >= 10) return 4;
    if (completed >= 6) return 3;
    if (completed >= 3) return 2;
    return 1;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
      _chapters = await ApiService.fetchChapters();
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
    notifyListeners();
  }

  void setNotificationTime(int hour, int minute, bool isAM) {
    _notificationHour = hour;
    _notificationMinute = minute;
    _isAM = isAM;
    notifyListeners();
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
    await _loadFavorites();
    await _loadThemePreference();
    await _loadUserProfile();
    await _loadBookmarkedChapters();
    await _loadJourneyData();
    await checkAndSetFirstLaunch();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favorites') ?? [];
    _favoriteKeys.addAll(saved);
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteKeys.toList());
  }

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

  // ── Journey Data Persistence ──

  Future<void> _saveJourneyData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('meditationStreak', _meditationStreak);
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
    _meditationStreak = prefs.getInt('meditationStreak') ?? 0;

    final completedStr = prefs.getStringList('chaptersCompleted') ?? [];
    _chaptersCompleted.addAll(completedStr.map((e) => int.parse(e)));

    final historyStr = prefs.getStringList('readingHistory') ?? [];
    _readingHistory =
        historyStr.map((e) => DateTime.parse(e)).toList();

    final achievementsStr = prefs.getString('userAchievements');
    if (achievementsStr != null) {
      _userAchievements =
          jsonDecode(achievementsStr) as Map<String, dynamic>;
    }
  }
}
