import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CalendarType {
  gregorian,
  ethiopian,
}

class SettingsState {
  final Locale locale;
  final ThemeMode themeMode;
  final CalendarType calendarType;

  SettingsState({
    required this.locale,
    required this.themeMode,
    required this.calendarType,
  });

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    CalendarType? calendarType,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      calendarType: calendarType ?? this.calendarType,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsController(this._prefs)
      : super(SettingsState(
          locale: Locale(_prefs.getString('language_code') ?? 'en'),
          themeMode: ThemeMode
              .values[_prefs.getInt('theme_mode') ?? ThemeMode.system.index],
          calendarType: CalendarType.values[
              _prefs.getInt('calendar_type') ?? CalendarType.gregorian.index],
        ));

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString('language_code', locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt('theme_mode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setCalendarType(CalendarType type) async {
    await _prefs.setInt('calendar_type', type.index);
    state = state.copyWith(calendarType: type);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsController(prefs);
});
