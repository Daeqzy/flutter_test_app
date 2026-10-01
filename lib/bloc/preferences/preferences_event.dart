import 'package:flutter/material.dart';

abstract class PreferencesEvent {
  const PreferencesEvent();
}

class PreferencesStarted extends PreferencesEvent {
  const PreferencesStarted();
}

class ThemeModeChanged extends PreferencesEvent {
  final ThemeMode themeMode;

  const ThemeModeChanged(this.themeMode);
}
