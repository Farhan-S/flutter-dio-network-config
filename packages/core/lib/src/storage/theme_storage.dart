import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local storage for app theme preferences
class ThemeStorage {
  static const String _themeModeKey = 'app_theme_mode';

  final SharedPreferences _prefs;

  ThemeStorage(this._prefs);

  /// Save theme mode to storage
  Future<bool> saveThemeMode(ThemeMode mode) async {
    debugPrint('💾 ThemeStorage - Saving theme: ${mode.name}');

    final result = await _prefs.setString(_themeModeKey, mode.name);

    if (result) {
      debugPrint('✅ ThemeStorage - Theme saved successfully');
    } else {
      debugPrint('❌ ThemeStorage - Failed to save theme');
    }

    return result;
  }

  /// Get saved theme mode from storage
  Future<ThemeMode?> getSavedThemeMode() async {
    final themeModeString = _prefs.getString(_themeModeKey);

    if (themeModeString == null) {
      debugPrint(
        'ℹ️  ThemeStorage - No saved theme found, using system default',
      );
      return null;
    }

    debugPrint('✅ ThemeStorage - Retrieved theme: $themeModeString');

    // Convert string to ThemeMode
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        debugPrint('⚠️  ThemeStorage - Unknown theme mode: $themeModeString');
        return ThemeMode.system;
    }
  }

  /// Clear saved theme (use system theme)
  Future<bool> clearThemeMode() async {
    debugPrint('🗑️  ThemeStorage - Clearing saved theme');
    final result = await _prefs.remove(_themeModeKey);

    if (result) {
      debugPrint('✅ ThemeStorage - Theme cleared successfully');
    }

    return result;
  }

  /// Check if theme is saved
  bool hasThemeMode() {
    return _prefs.containsKey(_themeModeKey);
  }
}
