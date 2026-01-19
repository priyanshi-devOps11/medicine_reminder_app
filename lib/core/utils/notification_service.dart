import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Service for managing medicine reminder notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> init() async {
    if (_isInitialized) {
      print('✅ Notification service already initialized');
      return;
    }

    try {
      print('🔔 Initializing notification service...');

      // Initialize timezone database
      tz.initializeTimeZones();
      final location = tz.getLocation('Asia/Kolkata'); // Set your timezone
      tz.setLocalLocation(location);
      print('✅ Timezone initialized: ${tz.local.name}');

      // Android-specific initialization
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      const initSettings = InitializationSettings(
        android: androidSettings,
      );

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      print('✅ Notifications initialized: $initialized');

      // Request required permissions
      await _requestPermissions();

      _isInitialized = true;
      print('✅ Notification service ready!');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
      rethrow;
    }
  }

  /// Request notification and alarm permissions
  Future<void> _requestPermissions() async {
    print('📱 Requesting permissions...');

    // Request notification permission (Android 13+)
    final notificationStatus = await Permission.notification.request();
    print('📱 Notification permission: $notificationStatus');

    // Request exact alarm permission (Android 12+)
    final alarmStatus = await Permission.scheduleExactAlarm.request();
    print('⏰ Exact alarm permission: $alarmStatus');

    if (notificationStatus.isDenied || alarmStatus.isDenied) {
      print('⚠️ Warning: Some permissions were denied');
    }
  }

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
  }

  /// Schedule a daily medicine reminder at the specified time
  Future<void> scheduleMedicineReminder({
    required int id,
    required String medicineName,
    required String dose,
    required DateTime scheduledTime,
  }) async {
    try {
      print('📅 Scheduling notification for: $medicineName at ${scheduledTime.hour}:${scheduledTime.minute}');

      final now = tz.TZDateTime.now(tz.local);

      // Create scheduled date for today at the specified time
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }


      print('🕐 Scheduled for: $scheduledDate');

      // Configure Android notification details
      final androidDetails = AndroidNotificationDetails(
        'medicine_reminder_channel',
        'Medicine Reminders',
        channelDescription: 'Daily reminders for taking medicines',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF009688),
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: const Color(0xFF009688),
        ledOnMs: 1000,
        ledOffMs: 500,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      // Schedule the notification
      await _notifications.zonedSchedule(
        id,
        '💊 Time for your medicine!',
        '$medicineName - $dose',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );

      print('✅ Notification scheduled successfully for ID: $id');

      // Verify scheduled notification
      final pendingNotifications = await _notifications.pendingNotificationRequests();
      print('📋 Total pending notifications: ${pendingNotifications.length}');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      rethrow;
    }
  }

  /// Show an immediate test notification
  Future<void> showTestNotification({
    required String medicineName,
    required String dose,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'medicine_reminder_channel',
        'Medicine Reminders',
        channelDescription: 'Daily reminders for taking medicines',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF009688),
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        DateTime.now().millisecond,
        '💊 Medicine Reminder Added!',
        '$medicineName - $dose will remind you daily',
        notificationDetails,
      );

      print('✅ Test notification shown');
    } catch (e) {
      print('❌ Error showing test notification: $e');
    }
  }

  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      print('✅ Cancelled notification: $id');
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }

  /// Get all pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}