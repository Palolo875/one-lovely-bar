import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class AppSettingsState {
  final ThemeMode themeMode;
  final String speedUnit;
  final String tempUnit;
  final String distanceUnit;

  const AppSettingsState({
    required this.themeMode,
    required this.speedUnit,
    required this.tempUnit,
    required this.distanceUnit,
  });

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    String? speedUnit,
    String? tempUnit,
    String? distanceUnit,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      speedUnit: speedUnit ?? this.speedUnit,
      tempUnit: tempUnit ?? this.tempUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  final Box _box;

  AppSettingsNotifier(this._box)
      : super(
          AppSettingsState(
            themeMode: _readThemeMode(_box),
            speedUnit: (_box.get('unit_speed', defaultValue: 'km/h') as String),
            tempUnit: (_box.get('unit_temp', defaultValue: '°C') as String),
            distanceUnit: (_box.get('unit_distance', defaultValue: 'km') as String),
          ),
        );

  static ThemeMode _readThemeMode(Box box) {
    final raw = box.get('theme_mode', defaultValue: 'system');
    if (raw == 'light') return ThemeMode.light;
    if (raw == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _box.put(
      'theme_mode',
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      },
    );
  }

  void setSpeedUnit(String value) {
    state = state.copyWith(speedUnit: value);
    _box.put('unit_speed', value);
  }

  void setTempUnit(String value) {
    state = state.copyWith(tempUnit: value);
    _box.put('unit_temp', value);
  }

  void setDistanceUnit(String value) {
    state = state.copyWith(distanceUnit: value);
    _box.put('unit_distance', value);
  }
}

final appSettingsProvider = StateNotifierProvider.autoDispose<AppSettingsNotifier, AppSettingsState>((ref) {
  final box = Hive.box('settings');
  return AppSettingsNotifier(box);
});
