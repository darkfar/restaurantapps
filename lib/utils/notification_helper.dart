// lib/utils/notification_helper.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../data/models/restaurant.dart';
import '../data/services/api_service.dart';

class NotificationHelper {
  static NotificationHelper? _instance;

  NotificationHelper._internal() {
    _instance = this;
  }

  factory NotificationHelper() => _instance ?? NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    await _configureLocalTimeZone();
    await _configureNotifications();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = Platform.isAndroid
        ? 'Asia/Jakarta'
        : await _getTimeZoneName();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<String> _getTimeZoneName() async {
    // For iOS, you might need to use a different approach
    // This is a simplified version
    return 'Asia/Jakarta';
  }

  Future<void> _configureNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        final String? payload = details.payload;
        if (payload != null) {
          debugPrint('notification payload: $payload');
        }
      },
    );

    // Request permissions for iOS
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Request permissions for Android 13+
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> scheduleDailyReminder() async {
    try {
      const int notificationId = 1;

      // Get random restaurant data
      final restaurant = await _getRandomRestaurant();

      final String title = 'Lunch Time! 🍽️';
      final String body = restaurant != null
          ? 'How about trying ${restaurant.name} in ${restaurant.city}? Rating: ${restaurant.rating}/5'
          : 'It\'s time for lunch! Discover amazing restaurants near you.';

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'daily_reminder_channel',
        'Daily Reminder',
        channelDescription: 'Daily lunch reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Daily Reminder',
        styleInformation: BigTextStyleInformation(''),
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails();

      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Schedule daily at 11:00 AM
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        _nextInstanceOfElevenAM(),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: restaurant != null ? jsonEncode(restaurant.toJson()) : null,
      );

      debugPrint('Daily reminder scheduled for 11:00 AM');
    } catch (e) {
      debugPrint('Error scheduling daily reminder: $e');
      rethrow;
    }
  }

  Future<Restaurant?> _getRandomRestaurant() async {
    try {
      final apiService = ApiService();
      final restaurants = await apiService.getRestaurantList();

      if (restaurants.isNotEmpty) {
        final random = Random();
        return restaurants[random.nextInt(restaurants.length)];
      }
    } catch (e) {
      debugPrint('Error fetching random restaurant: $e');
    }
    return null;
  }

  tz.TZDateTime _nextInstanceOfElevenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      11, // 11 AM
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelDailyReminder() async {
    try {
      await flutterLocalNotificationsPlugin.cancel(1);
      debugPrint('Daily reminder cancelled');
    } catch (e) {
      debugPrint('Error cancelling daily reminder: $e');
      rethrow;
    }
  }

  Future<void> showInstantNotification(String title, String body) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'instant_notification_channel',
        'Instant Notifications',
        channelDescription: 'Instant notification messages',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Instant Notification',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails();

      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        0, // notification id
        title,
        body,
        platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
      rethrow;
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}