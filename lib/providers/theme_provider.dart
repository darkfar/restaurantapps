// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import '../data/preferences/preferences_helper.dart';

class ThemeProvider extends ChangeNotifier {
  final PreferencesHelper preferencesHelper;

  ThemeProvider({required this.preferencesHelper}) {
    _loadThemePreference();
  }

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isDarkMode = await preferencesHelper.isDarkTheme;
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
      _isDarkMode = false; // Default to light theme on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle theme and save to preferences
  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;
      await preferencesHelper.setDarkTheme(_isDarkMode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
      // Revert if save failed
      _isDarkMode = !_isDarkMode;
      notifyListeners();
    }
  }

  // Set specific theme and save to preferences
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode == isDark) return;

    try {
      _isDarkMode = isDark;
      await preferencesHelper.setDarkTheme(_isDarkMode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
      // Revert if save failed
      _isDarkMode = !isDark;
      notifyListeners();
    }
  }

  // Get current theme mode
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Get theme name for display
  String get themeName => _isDarkMode ? 'Dark Theme' : 'Light Theme';

  // Refresh theme preference
  Future<void> refreshTheme() async {
    await _loadThemePreference();
  }
}