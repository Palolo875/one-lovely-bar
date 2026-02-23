import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weathernav/core/logging/app_logger.dart';
import 'package:weathernav/core/storage/settings_keys.dart';
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

class AppSettingsNotifier extends Notifier<AppSettingsState> {
  late final SettingsRepository _settings;
  final List<StreamSubscription<void>> _subs = [];

  @override
  AppSettingsState build() {
    _settings = ref.watch(settingsRepositoryProvider);

    var syncScheduled = false;
    void sync() {
      final next = AppSettingsState(
        themeMode: _readThemeMode(_settings),
        speedUnit: _settings.getOrDefault<String>(
          SettingsKeys.unitSpeed,
          'km/h',
        ),
        tempUnit: _settings.getOrDefault<String>(SettingsKeys.unitTemp, '°C'),
        distanceUnit: _settings.getOrDefault<String>(
          SettingsKeys.unitDistance,
          'km',
        ),
      );
      if (next.themeMode != state.themeMode ||
          next.speedUnit != state.speedUnit ||
          next.tempUnit != state.tempUnit ||
          next.distanceUnit != state.distanceUnit) {
        state = next;
      }
    }

    void scheduleSync() {
      if (syncScheduled) return;
      syncScheduled = true;
      scheduleMicrotask(() {
        syncScheduled = false;
        sync();
      });
    }

    for (final key in const [
      SettingsKeys.themeMode,
      SettingsKeys.unitSpeed,
      SettingsKeys.unitTemp,
      SettingsKeys.unitDistance,
    ]) {
      _subs.add(_settings.watch(key).listen((_) => scheduleSync()));
    }

    ref.onDispose(() {
      for (final s in _subs) {
        s.cancel();
      }
    });

    return AppSettingsState(
      themeMode: _readThemeMode(_settings),
      speedUnit: _settings.getOrDefault<String>(SettingsKeys.unitSpeed, 'km/h'),
      tempUnit: _settings.getOrDefault<String>(SettingsKeys.unitTemp, '°C'),
      distanceUnit: _settings.getOrDefault<String>(
        SettingsKeys.unitDistance,
        'km',
      ),
    );
  }

  static ThemeMode _readThemeMode(SettingsRepository settings) {
    final raw = settings.getOrDefault<String>(SettingsKeys.themeMode, 'system');
    if (raw == 'light') return ThemeMode.light;
    if (raw == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prev = state;
    try {
      await _settings.put(SettingsKeys.themeMode, switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      });
      state = state.copyWith(themeMode: mode);
    } catch (e, st) {
      AppLogger.error(
        'Failed to persist theme mode',
        name: 'settings',
        error: e,
        stackTrace: st,
      );
      state = prev;
    }
  }

  Future<void> setSpeedUnit(String value) async {
    final prev = state;
    try {
      await _settings.put(SettingsKeys.unitSpeed, value);
      state = state.copyWith(speedUnit: value);
    } catch (e, st) {
      AppLogger.error(
        'Failed to persist speed unit',
        name: 'settings',
        error: e,
        stackTrace: st,
      );
      state = prev;
    }
  }

  Future<void> setTempUnit(String value) async {
    final prev = state;
    try {
      await _settings.put(SettingsKeys.unitTemp, value);
      state = state.copyWith(tempUnit: value);
    } catch (e, st) {
      AppLogger.error(
        'Failed to persist temperature unit',
        name: 'settings',
        error: e,
        stackTrace: st,
      );
      state = prev;
    }
  }

  Future<void> setDistanceUnit(String value) async {
    final prev = state;
    try {
      await _settings.put(SettingsKeys.unitDistance, value);
      state = state.copyWith(distanceUnit: value);
    } catch (e, st) {
      AppLogger.error(
        'Failed to persist distance unit',
        name: 'settings',
        error: e,
        stackTrace: st,
      );
      state = prev;
    }
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsState>(
      AppSettingsNotifier.new,
    );

class OnboardingStatusNotifier extends Notifier<bool> {
  late final SettingsRepository _settings;
  StreamSubscription<void>? _sub;

  @override
  bool build() {
    _settings = ref.watch(settingsRepositoryProvider);

    _sub = _settings.watch(SettingsKeys.onboardingCompleted).listen((event) {
      final next =
          _settings.getOrDefault<bool>(
            SettingsKeys.onboardingCompleted,
            false,
          ) ==
          true;
      if (next != state) state = next;
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return _settings.getOrDefault<bool>(
          SettingsKeys.onboardingCompleted,
          false,
        ) ==
        true;
  }

  Future<bool> setCompleted(bool value) async {
    if (value == state) return true;
    final prev = state;
    try {
      await _settings.put(SettingsKeys.onboardingCompleted, value);
      state = value;
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to persist onboarding completion',
        name: 'settings',
        error: e,
        stackTrace: st,
      );
      state = prev;
      return false;
    }
  }
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingStatusNotifier, bool>(
      OnboardingStatusNotifier.new,
    );
