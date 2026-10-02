import 'package:flutter/material.dart';

class PreferencesState {
  final ThemeMode themeMode;
  final bool isLoading;

  const PreferencesState({
    this.themeMode = ThemeMode.system,
    this.isLoading = true,
  });

  PreferencesState copyWith({ThemeMode? themeMode, bool? isLoading}) {
    return PreferencesState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
