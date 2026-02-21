import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/models/user_profile.dart';
import 'profile_provider.dart';

enum WeatherLayer {
  radar,
  wind,
  temperature,
}

class WeatherLayersState {
  final Set<WeatherLayer> enabled;

  const WeatherLayersState({required this.enabled});

  WeatherLayersState copyWith({Set<WeatherLayer>? enabled}) {
    return WeatherLayersState(enabled: enabled ?? this.enabled);
  }
}

class WeatherLayersNotifier extends StateNotifier<WeatherLayersState> {
  final Box _settings;

  WeatherLayersNotifier(this._settings, Set<WeatherLayer> initial)
      : super(WeatherLayersState(enabled: initial));

  static const _key = 'enabled_weather_layers';

  void toggle(WeatherLayer layer) {
    final next = Set<WeatherLayer>.from(state.enabled);
    if (next.contains(layer)) {
      next.remove(layer);
    } else {
      next.add(layer);
    }
    state = state.copyWith(enabled: next);
    _persist(next);
  }

  void setEnabled(Set<WeatherLayer> enabled) {
    state = state.copyWith(enabled: enabled);
    _persist(enabled);
  }

  void resetToProfile(UserProfile profile) {
    final defaults = <WeatherLayer>{};
    for (final l in profile.defaultLayers) {
      switch (l) {
        case 'precipitation':
          defaults.add(WeatherLayer.radar);
          break;
        case 'wind':
          defaults.add(WeatherLayer.wind);
          break;
        case 'temp':
          defaults.add(WeatherLayer.temperature);
          break;
        default:
          break;
      }
    }
    setEnabled(defaults);
  }

  void _persist(Set<WeatherLayer> enabled) {
    _settings.put(_key, enabled.map((e) => e.name).toList());
  }

  static Set<WeatherLayer> load(Box settings, UserProfile profile) {
    final raw = settings.get(_key);
    if (raw is List) {
      final enabled = <WeatherLayer>{};
      for (final v in raw) {
        if (v is! String) continue;
        final match = WeatherLayer.values.where((e) => e.name == v).toList();
        if (match.isNotEmpty) enabled.add(match.first);
      }
      return enabled;
    }

    // fallback to profile defaults
    final defaults = <WeatherLayer>{};
    for (final l in profile.defaultLayers) {
      switch (l) {
        case 'precipitation':
          defaults.add(WeatherLayer.radar);
          break;
        case 'wind':
          defaults.add(WeatherLayer.wind);
          break;
        case 'temp':
          defaults.add(WeatherLayer.temperature);
          break;
        default:
          break;
      }
    }
    return defaults;
  }
}

final weatherLayersProvider = StateNotifierProvider.autoDispose<WeatherLayersNotifier, WeatherLayersState>((ref) {
  final settings = Hive.box('settings');
  final profile = ref.watch(profileNotifierProvider);
  final initial = WeatherLayersNotifier.load(settings, profile);
  return WeatherLayersNotifier(settings, initial);
});
