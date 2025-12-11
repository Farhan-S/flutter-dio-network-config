import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/theme_storage.dart';

/// Theme Cubit for managing app theme mode with persistence
class ThemeCubit extends Cubit<ThemeMode> {
  final ThemeStorage _themeStorage;

  ThemeCubit(this._themeStorage) : super(ThemeMode.system) {
    // Load saved theme on initialization
    _loadSavedTheme();
  }

  /// Load saved theme from storage
  Future<void> _loadSavedTheme() async {
    final savedTheme = await _themeStorage.getSavedThemeMode();
    if (savedTheme != null) {
      debugPrint('🎨 ThemeCubit - Loaded saved theme: ${savedTheme.name}');
      emit(savedTheme);
    } else {
      debugPrint('🎨 ThemeCubit - No saved theme, using system default');
    }
  }

  /// Current theme mode
  ThemeMode get themeMode => state;

  /// Is dark mode enabled
  bool get isDarkMode => state == ThemeMode.dark;

  /// Is light mode enabled
  bool get isLightMode => state == ThemeMode.light;

  /// Is system mode enabled
  bool get isSystemMode => state == ThemeMode.system;

  /// Set theme mode and persist to storage
  Future<void> setThemeMode(ThemeMode mode) async {
    debugPrint('🎨 ThemeCubit - Setting theme: ${mode.name}');
    emit(mode);
    await _themeStorage.saveThemeMode(mode);
  }

  /// Toggle between light and dark
  Future<void> toggleTheme() async {
    ThemeMode newMode;
    if (state == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else if (state == ThemeMode.dark) {
      newMode = ThemeMode.light;
    } else {
      // If system, switch to light
      newMode = ThemeMode.light;
    }
    await setThemeMode(newMode);
  }

  /// Set to dark mode
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Set to light mode
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set to system mode
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }
}
