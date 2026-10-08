import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme state — tracks whether dark mode is active.
enum ThemeModeState { light, dark }

/// ThemeCubit — manages application theme state with SharedPreferences persistence.
class ThemeCubit extends Cubit<ThemeModeState> {
  static const String _keyIsDarkMode = 'is_dark_mode';

  final SharedPreferences _prefs;

  ThemeCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(prefs.getBool(_keyIsDarkMode) ?? true ? ThemeModeState.dark : ThemeModeState.light);

  /// Toggles between light and dark theme and persists the selection.
  void toggleTheme() {
    final newState = state == ThemeModeState.dark ? ThemeModeState.light : ThemeModeState.dark;
    _saveTheme(newState);
    emit(newState);
  }

  /// Sets the theme mode explicitly and persists the selection.
  void setTheme(ThemeModeState mode) {
    _saveTheme(mode);
    emit(mode);
  }

  /// Returns the Flutter ThemeMode for MaterialApp.
  ThemeMode get materialThemeMode {
    return state == ThemeModeState.dark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Saves the theme preference to SharedPreferences.
  void _saveTheme(ThemeModeState mode) {
    _prefs.setBool(_keyIsDarkMode, mode == ThemeModeState.dark);
  }
}
