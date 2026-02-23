import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weathernav/core/logging/app_logger.dart';
import 'package:weathernav/core/storage/settings_keys.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';

class AlertThresholdsState {
  const AlertThresholdsState({required this.values});
  final Map<String, double> values;

  AlertThresholdsState copyWith({Map<String, double>? values}) {
    return AlertThresholdsState(values: values ?? this.values);
  }
}

class AlertThresholdsNotifier extends Notifier<AlertThresholdsState> {
  late final SettingsRepository _settings;
  StreamSubscription? _sub;
  Timer? _persistDebounce;

  @override
  AlertThresholdsState build() {
    _settings = ref.watch(settingsRepositoryProvider);

    var syncScheduled = false;
    void sync() {
      final next = _read(_settings);
      if (!_same(next, state.values)) {
        state = state.copyWith(values: next);
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

    _sub = _settings
        .watch(SettingsKeys.alertThresholds)
        .listen((_) => scheduleSync());

    ref.onDispose(() {
      _persistDebounce?.cancel();
      _sub?.cancel();
    });

    return AlertThresholdsState(values: _read(_settings));
  }

  static Map<String, double> _read(SettingsRepository settings) {
    final raw = settings.get<Object?>(SettingsKeys.alertThresholds);
    if (raw is Map) {
      final out = <String, double>{};
      for (final e in raw.entries) {
        final k = e.key?.toString();
        final v = e.value;
        if (k == null || v is! num) continue;
        out[k] = v.toDouble();
      }
      if (out.isNotEmpty) return out;
    }

    return {
      'precipitation_mm': 1.0,
      'wind_kmh': 35.0,
      'temp_low_c': -2.0,
      'temp_high_c': 35.0,
    };
  }

  static bool _same(Map<String, double> a, Map<String, double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      final other = b[e.key];
      if (other == null) return false;
      if (other != e.value) return false;
    }
    return true;
  }

  Future<void> _persistNow(Map<String, double> values) async {
    try {
      await _settings.put(SettingsKeys.alertThresholds, values);
    } catch (e, st) {
      AppLogger.error(
        'Failed to persist alert thresholds',
        name: 'settings',
        error: e,
        stackTrace: st,
      );
      final next = _read(_settings);
      if (!_same(next, state.values)) {
        state = state.copyWith(values: next);
      }
    }
  }

  void setValue(String key, double value) {
    final next = Map<String, double>.from(state.values);
    next[key] = value;
    state = state.copyWith(values: next);
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 250), () {
      unawaited(_persistNow(next));
    });
  }

  Future<void> resetDefaults() async {
    final prev = state;
    _persistDebounce?.cancel();
    _persistDebounce = null;
    try {
      await _settings.delete(SettingsKeys.alertThresholds);
      state = state.copyWith(values: _read(_settings));
    } catch (e, st) {
      AppLogger.error(
        'Failed to reset alert thresholds',
        name: 'settings',
        error: e,
        stackTrace: st,
      );
      state = prev;
    }
  }
}

final alertThresholdsProvider =
    NotifierProvider<AlertThresholdsNotifier, AlertThresholdsState>(
      AlertThresholdsNotifier.new,
    );
