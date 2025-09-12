// lib/utils/background_service.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/models/restaurant.dart';
import '../data/services/api_service.dart';
import 'notification_helper.dart';

class BackgroundService {
  static BackgroundService? _instance;
  final NotificationHelper _notificationHelper;

  BackgroundService._internal() : _notificationHelper = NotificationHelper();

  factory BackgroundService() {
    return _instance ??= BackgroundService._internal();
  }

  Future<void> initializeService() async {
    try {
      await _notificationHelper.initNotifications();
      debugPrint('Background service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize background service: $e');
    }
  }

  Future<void> showDailyReminderNotification() async {
    try {
      // Fetch random restaurant data
      final restaurant = await _getRandomRestaurant();

      final String title = 'Lunch Time!';
      final String body = restaurant != null
          ? 'How about trying ${restaurant.name} in ${restaurant.city}? Rating: ${restaurant.rating}/5'
          : 'It\'s time for lunch! Discover amazing restaurants near you.';

      await _notificationHelper.showInstantNotification(title, body);
    } catch (e) {
      debugPrint('Error showing daily reminder: $e');
      // Fallback notification
      await _notificationHelper.showInstantNotification(
        'Lunch Time!',
        'It\'s time for lunch! Discover amazing restaurants near you.',
      );
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

  Future<void> scheduleBackgroundTasks() async {
    try {
      await _notificationHelper.scheduleDailyReminder();
      debugPrint('Background tasks scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling background tasks: $e');
    }
  }

  Future<void> cancelAllBackgroundTasks() async {
    try {
      await _notificationHelper.cancelAllNotifications();
      debugPrint('All background tasks cancelled');
    } catch (e) {
      debugPrint('Error cancelling background tasks: $e');
    }
  }

  Future<void> handleBackgroundMessage() async {
    // This would be called by a background service like WorkManager
    await showDailyReminderNotification();
  }
}