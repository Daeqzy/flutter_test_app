import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themeModeKey = 'theme_mode';

  // ----------------------------------------------------------
  // LOAD THEME
  // ----------------------------------------------------------

  Future<ThemeMode> loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();

    final savedTheme = preferences.getString(_themeModeKey);

    switch (savedTheme) {
      case 'light':
        return ThemeMode.light;

      case 'dark':
        return ThemeMode.dark;

      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  // ----------------------------------------------------------
  // SAVE THEME
  // ----------------------------------------------------------

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final preferences = await SharedPreferences.getInstance();

    final value = switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await preferences.setString(_themeModeKey, value);
  }
}
