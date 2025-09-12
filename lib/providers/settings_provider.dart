// lib/providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import '../data/preferences/preferences_helper.dart';
import '../utils/notification_helper.dart';

class SettingsProvider extends ChangeNotifier {
  final PreferencesHelper preferencesHelper;
  final NotificationHelper notificationHelper;

  SettingsProvider({
    required this.preferencesHelper,
    required this.notificationHelper,
  }) {
    _loadSettings();
  }

  bool _isDailyReminderActive = false;
  bool get isDailyReminderActive => _isDailyReminderActive;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Load settings from preferences
  Future<void> _loadSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _isDailyReminderActive = await preferencesHelper.isDailyReminderActive;
    } catch (e) {
      _errorMessage = 'Failed to load settings: $e';
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle daily reminder
  Future<void> toggleDailyReminder(bool value) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (value) {
        // Schedule daily notification
        await notificationHelper.scheduleDailyReminder();
      } else {
        // Cancel daily notification
        await notificationHelper.cancelDailyReminder();
      }

      // Save preference
      await preferencesHelper.setDailyReminder(value);
      _isDailyReminderActive = value;
    } catch (e) {
      _errorMessage = 'Failed to update daily reminder: $e';
      debugPrint('Error updating daily reminder: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh settings
  Future<void> refreshSettings() async {
    await _loadSettings();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset all settings
  Future<void> resetSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await preferencesHelper.clearAllPreferences();
      await notificationHelper.cancelDailyReminder();

      _isDailyReminderActive = false;
    } catch (e) {
      _errorMessage = 'Failed to reset settings: $e';
      debugPrint('Error resetting settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}