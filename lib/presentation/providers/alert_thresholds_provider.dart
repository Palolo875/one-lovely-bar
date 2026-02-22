import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';

class AlertThresholdsState {

  const AlertThresholdsState({required this.values});
  final Map<String, double> values;

  AlertThresholdsState copyWith({Map<String, double>? values}) {
    return AlertThresholdsState(values: values ?? this.values);
  }
}

class AlertThresholdsNotifier extends StateNotifier<AlertThresholdsState> {

  AlertThresholdsNotifier(this._settings)
      : super(
          AlertThresholdsState(
            values: _read(_settings),
          ),
        );
  final SettingsRepository _settings;

  static const _key = 'alert_thresholds';

  static Map<String, double> _read(SettingsRepository settings) {
    final raw = settings.get<dynamic>(_key);
    if (raw is Map) {
      final out = <String, double>{};
      for (final e in raw.entries) {
        final k = e.key;
        final v = e.value;
        if (k is String && v is num) {
          out[k] = v.toDouble();
        }
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

  void setValue(String key, double value) {
    final next = Map<String, double>.from(state.values);
    next[key] = value;
    state = state.copyWith(values: next);
    _settings.put(_key, next);
  }

  void resetDefaults() {
    _settings.delete(_key);
    state = state.copyWith(values: _read(_settings));
  }
}

final alertThresholdsProvider = StateNotifierProvider.autoDispose<AlertThresholdsNotifier, AlertThresholdsState>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return AlertThresholdsNotifier(settings);
});
