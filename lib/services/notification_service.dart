import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:lume/core/constants/app_strings.dart';

/// Service for managing local push notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification plugin. Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(iOS: iosSettings);
    await _plugin.initialize(settings: initSettings);
    _initialized = true;
  }

  /// Request notification permissions (iOS).
  Future<bool> requestPermission() async {
    final result = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return result ?? false;
  }

  /// Schedule a daily reading reminder at the specified [time].
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await requestPermission();
    await cancelReminder();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, time.hour, time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: 0,
      title: AppStrings.notificationTitle,
      body: AppStrings.notificationBody,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel the daily reading reminder.
  Future<void> cancelReminder() async {
    await _plugin.cancel(id: 0);
  }
}
