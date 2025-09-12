// lib/data/preferences/preferences_helper.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  final Future<SharedPreferences> sharedPreferences;

  PreferencesHelper({required this.sharedPreferences});

  static const String _isDarkTheme = 'isDarkTheme';
  static const String _isDailyReminderActive = 'isDailyReminderActive';

  // Theme preferences
  Future<bool> get isDarkTheme async {
    final prefs = await sharedPreferences;
    return prefs.getBool(_isDarkTheme) ?? false;
  }

  Future<bool> setDarkTheme(bool value) async {
    final prefs = await sharedPreferences;
    return prefs.setBool(_isDarkTheme, value);
  }

  // Daily reminder preferences
  Future<bool> get isDailyReminderActive async {
    final prefs = await sharedPreferences;
    return prefs.getBool(_isDailyReminderActive) ?? false;
  }

  Future<bool> setDailyReminder(bool value) async {
    final prefs = await sharedPreferences;
    return prefs.setBool(_isDailyReminderActive, value);
  }

  // Clear all preferences
  Future<bool> clearAllPreferences() async {
    final prefs = await sharedPreferences;
    return prefs.clear();
  }
}