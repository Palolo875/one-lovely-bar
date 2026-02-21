import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

class AlertThresholdsState {
  final Map<String, double> values;

  const AlertThresholdsState({required this.values});

  AlertThresholdsState copyWith({Map<String, double>? values}) {
    return AlertThresholdsState(values: values ?? this.values);
  }
}

class AlertThresholdsNotifier extends StateNotifier<AlertThresholdsState> {
  final Box _box;

  AlertThresholdsNotifier(this._box)
      : super(
          AlertThresholdsState(
            values: _read(_box),
          ),
        );

  static const _key = 'alert_thresholds';

  static Map<String, double> _read(Box box) {
    final raw = box.get(_key);
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
    _box.put(_key, next);
  }

  void resetDefaults() {
    _box.delete(_key);
    state = state.copyWith(values: _read(_box));
  }
}

final alertThresholdsProvider = StateNotifierProvider.autoDispose<AlertThresholdsNotifier, AlertThresholdsState>((ref) {
  final box = Hive.box('settings');
  return AlertThresholdsNotifier(box);
});
