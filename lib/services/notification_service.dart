import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/app_settings.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int afternoonId = 101;
  static const int eveningId = 102;
  static const String channelId = 'mess_meal_reminders';
  static const String channelName = 'Mess Meal Reminders';
  static const String channelDescription =
      'Daily reminders for afternoon and evening college mess meals';

  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Initialize timezone database
    try {
      tz.initializeTimeZones();
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (e) {
      debugPrint('Error setting up timezone: $e');
    }

    // 2. Android Initialization Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        selectNotificationStream.add(response.payload);
      },
    );

    _isInitialized = true;
  }

  /// Request permissions for Android 13+ (POST_NOTIFICATIONS) and Exact Alarms
  Future<bool> requestPermissions() async {
    final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final notifGranted = await androidImpl.requestNotificationsPermission();
      final alarmGranted = await androidImpl.requestExactAlarmsPermission();
      return (notifGranted ?? false) && (alarmGranted ?? false);
    }
    return true;
  }

  /// Sync scheduled reminders based on today's meal status and settings
  Future<void> syncReminders({
    required AppSettings settings,
    required bool isAfternoonMarkedToday,
    required bool isEveningMarkedToday,
  }) async {
    if (!settings.notificationsEnabled) {
      await cancelAllReminders();
      return;
    }

    // Schedule Afternoon reminder
    await _scheduleMealReminder(
      id: afternoonId,
      timeString: settings.afternoonReminder,
      title: '🍱 Afternoon Meal Reminder',
      body:
          "Have you eaten your afternoon meal? Don't forget to update your Mess app!",
      isAlreadyMarkedToday: isAfternoonMarkedToday,
    );

    // Schedule Evening reminder
    await _scheduleMealReminder(
      id: eveningId,
      timeString: settings.eveningReminder,
      title: '🌙 Evening Meal Reminder',
      body:
          "Have you eaten your evening meal? Update your meal tracker!",
      isAlreadyMarkedToday: isEveningMarkedToday,
    );
  }

  Future<void> _scheduleMealReminder({
    required int id,
    required String timeString,
    required String title,
    required String body,
    required bool isAlreadyMarkedToday,
  }) async {
    try {
      // First cancel existing to prevent duplicates
      await _notificationsPlugin.cancel(id);

      final parts = timeString.split(':');
      if (parts.length < 2) return;
      final hour = int.tryParse(parts[0]) ?? 14;
      final minute = int.tryParse(parts[1]) ?? 0;

      final scheduledDate = _nextOccurrence(hour, minute, skipToday: isAlreadyMarkedToday);

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'today_meal',
      );
    } catch (e) {
      debugPrint('Failed to schedule notification $id: $e');
    }
  }

  tz.TZDateTime _nextOccurrence(int hour, int minute, {required bool skipToday}) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If today is already marked, or if the time has already passed today, start from tomorrow
    if (skipToday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancel(afternoonId);
    await _notificationsPlugin.cancel(eveningId);
  }

  /// Test notification trigger immediately
  Future<void> showTestNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      999,
      title,
      body,
      details,
      payload: 'today_meal',
    );
  }
}
