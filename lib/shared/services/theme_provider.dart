// This provider manages the app's theme mode (light/dark) and toggling.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_theme.dart';

/// Provider for theme state management
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Loads the saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      state = ThemeMode.values[themeIndex];
    } catch (e) {
      // Default to system theme if loading fails
      state = ThemeMode.system;
    }
  }

  /// Saves the current theme to SharedPreferences
  Future<void> _saveTheme(ThemeMode theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Sets the theme mode
  Future<void> setTheme(ThemeMode theme) async {
    state = theme;
    await _saveTheme(theme);
  }

  /// Toggles between light and dark themes
  Future<void> toggleTheme() async {
    final newTheme =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(newTheme);
  }

  /// Gets the current theme mode as a string
  String get themeModeString {
    switch (state) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Gets the theme icon based on current mode
  IconData get themeIcon {
    switch (state) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

/// Provider for theme notifier
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Provider for the current theme data
final themeDataProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeProvider);

  switch (themeMode) {
    case ThemeMode.light:
      return AppTheme.lightTheme;
    case ThemeMode.dark:
      return AppTheme.darkTheme;
    case ThemeMode.system:
      // This will be handled by the app's theme mode
      return AppTheme.lightTheme;
  }
});

/// Provider for checking if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);

  switch (themeMode) {
    case ThemeMode.light:
      return false;
    case ThemeMode.dark:
      return true;
    case ThemeMode.system:
      // This should be determined by the system, but we'll default to false
      return false;
  }
});
