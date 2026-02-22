import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';

class AppSettingsState {

  const AppSettingsState({
    required this.themeMode,
    required this.speedUnit,
    required this.tempUnit,
    required this.distanceUnit,
  });
  final ThemeMode themeMode;
  final String speedUnit;
  final String tempUnit;
  final String distanceUnit;

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

  AppSettingsNotifier(this._settings)
      : super(
          AppSettingsState(
            themeMode: _readThemeMode(_settings),
            speedUnit: _settings.getOrDefault<String>('unit_speed', 'km/h'),
            tempUnit: _settings.getOrDefault<String>('unit_temp', '°C'),
            distanceUnit: _settings.getOrDefault<String>('unit_distance', 'km'),
          ),
        ) {
    void sync() {
      final next = AppSettingsState(
        themeMode: _readThemeMode(_settings),
        speedUnit: _settings.getOrDefault<String>('unit_speed', 'km/h'),
        tempUnit: _settings.getOrDefault<String>('unit_temp', '°C'),
        distanceUnit: _settings.getOrDefault<String>('unit_distance', 'km'),
      );
      if (next.themeMode != state.themeMode ||
          next.speedUnit != state.speedUnit ||
          next.tempUnit != state.tempUnit ||
          next.distanceUnit != state.distanceUnit) {
        state = next;
      }
    }

    for (final key in const ['theme_mode', 'unit_speed', 'unit_temp', 'unit_distance']) {
      _subs.add(
        _settings.watch(key).listen((_) => sync()),
      );
    }
  }
  final SettingsRepository _settings;
  final List<StreamSubscription> _subs = [];

  static ThemeMode _readThemeMode(SettingsRepository settings) {
    final raw = settings.getOrDefault<String>('theme_mode', 'system');
    if (raw == 'light') return ThemeMode.light;
    if (raw == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _settings.put(
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
    _settings.put('unit_speed', value);
  }

  void setTempUnit(String value) {
    state = state.copyWith(tempUnit: value);
    _settings.put('unit_temp', value);
  }

  void setDistanceUnit(String value) {
    state = state.copyWith(distanceUnit: value);
    _settings.put('unit_distance', value);
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}

final appSettingsProvider = StateNotifierProvider.autoDispose<AppSettingsNotifier, AppSettingsState>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return AppSettingsNotifier(settings);
});

class OnboardingStatusNotifier extends StateNotifier<bool> {

  OnboardingStatusNotifier(this._settings)
      : super(_settings.getOrDefault<bool>(_key, false) == true) {
    _sub = _settings.watch(_key).listen((event) {
      final next = _settings.getOrDefault<bool>(_key, false) == true;
      if (next != state) state = next;
    });
  }
  static const _key = 'onboarding_completed';

  final SettingsRepository _settings;
  StreamSubscription? _sub;

  Future<void> setCompleted(bool value) async {
    if (value == state) return;
    state = value;
    await _settings.put(_key, value);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final onboardingCompletedProvider = StateNotifierProvider.autoDispose<OnboardingStatusNotifier, bool>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return OnboardingStatusNotifier(settings);
});
