import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Top-level function for background notification handling (required for v20+)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Handle background notification tap
  debugPrint('Background notification tapped: ${response.payload}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification system. Call once on app startup.
  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    _initialized = true;
  }

  /// Request notification permissions (Android 13+ / iOS).
  Future<bool> requestPermissions() async {
    // Android
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    // iOS
    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  /// Schedule a daily notification at the given hour/minute (24-hour format).
  Future<void> scheduleDailyQuote({
    required int hour,
    required int minute,
  }) async {
    // Cancel any existing scheduled notification first
    await _plugin.cancel(id: 0);

    // Save schedule preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_hour', hour);
    await prefs.setInt('notif_minute', minute);
    await prefs.setBool('notif_enabled', true);

    // Pick a random inspirational verse snippet
    final quotes = [
      'You have the right to work, but never to the fruit of work. — BG 2.47',
      'The soul is neither born, and nor does it die. — BG 2.20',
      'Perform your duty with a calm mind. — BG 2.48',
      'When meditation is mastered, the mind is unwavering like the flame of a candle in a windless place. — BG 6.19',
      'Set thy heart upon thy work, but never on its reward. — BG 2.47',
      'Change is the law of the universe. — BG 2.22',
      'The mind acts like an enemy for those who do not control it. — BG 6.6',
      'There is neither this world, nor the world beyond, nor happiness for the one who doubts. — BG 4.40',
    ];
    final quote = quotes[Random().nextInt(quotes.length)];

    const androidDetails = AndroidNotificationDetails(
      'daily_quotes',
      'Daily Wisdom Quotes',
      channelDescription: 'Daily Bhagavad Gita verse notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If that time has already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: 0,
      title: '🙏 Daily Wisdom',
      body: quote,
      scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_enabled', false);
  }

  /// Restore notification schedule from saved preferences.
  Future<void> restoreSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notif_enabled') ?? false;
    if (!enabled) return;

    final hour = prefs.getInt('notif_hour') ?? 6;
    final minute = prefs.getInt('notif_minute') ?? 30;

    await scheduleDailyQuote(hour: hour, minute: minute);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // The app is simply opened — the user can navigate from there.
    // Deep linking to a specific verse could be added later.
    debugPrint('Notification tapped: ${response.payload}');
  }
}
