import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/presentation/providers/profile_provider.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';

enum WeatherLayer {
  radar,
  wind,
  temperature,
}

class WeatherLayersState {

  const WeatherLayersState({required this.enabled, required this.order, required this.opacity});
  final Set<WeatherLayer> enabled;
  final List<WeatherLayer> order;
  final Map<WeatherLayer, double> opacity;

  WeatherLayersState copyWith({Set<WeatherLayer>? enabled, List<WeatherLayer>? order, Map<WeatherLayer, double>? opacity}) {
    return WeatherLayersState(
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
      opacity: opacity ?? this.opacity,
    );
  }
}

class WeatherLayersNotifier extends StateNotifier<WeatherLayersState> {

  WeatherLayersNotifier(this._settings, Set<WeatherLayer> initial)
      : super(
          WeatherLayersState(
            enabled: initial,
            order: _loadOrder(_settings, initial),
            opacity: _loadOpacity(_settings),
          ),
        );
  final SettingsRepository _settings;

  static const _key = 'enabled_weather_layers';
  static const _opacityKey = 'weather_layer_opacity';
  static const _orderKey = 'weather_layer_order';
  static const int maxEnabled = 3;
  static const double maxOpacity = 0.70;

  void toggle(WeatherLayer layer) {
    final next = Set<WeatherLayer>.from(state.enabled);
    if (next.contains(layer)) {
      next.remove(layer);
    } else {
      if (next.length >= maxEnabled) {
        return;
      }
      next.add(layer);
    }
    final nextOrder = _normalizeOrder(state.order, next);
    state = state.copyWith(enabled: next, order: nextOrder);
    _persist(next);
    _persistOrder(nextOrder);
  }

  void setEnabled(Set<WeatherLayer> enabled) {
    final next = enabled.length <= maxEnabled ? enabled : enabled.take(maxEnabled).toSet();
    final nextOrder = _normalizeOrder(state.order, next);
    state = state.copyWith(enabled: next, order: nextOrder);
    _persist(next);
    _persistOrder(nextOrder);
  }

  void moveLayer(WeatherLayer layer, int newIndex) {
    final enabled = state.enabled;
    if (!enabled.contains(layer)) return;
    final order = _normalizeOrder(state.order, enabled);
    final cur = order.indexOf(layer);
    if (cur < 0) return;
    final next = List<WeatherLayer>.from(order);
    next.removeAt(cur);
    final idx = newIndex.clamp(0, next.length);
    next.insert(idx, layer);
    state = state.copyWith(order: next);
    _persistOrder(next);
  }

  void setOpacity(WeatherLayer layer, double value) {
    final next = Map<WeatherLayer, double>.from(state.opacity);
    next[layer] = value.clamp(0.0, maxOpacity);
    state = state.copyWith(opacity: next);
    _persistOpacity(next);
  }

  void resetToProfile(UserProfile profile) {
    final defaults = <WeatherLayer>{};
    for (final l in profile.defaultLayers) {
      switch (l) {
        case 'precipitation':
          defaults.add(WeatherLayer.radar);
        case 'wind':
          defaults.add(WeatherLayer.wind);
        case 'temp':
          defaults.add(WeatherLayer.temperature);
        default:
          break;
      }
    }
    setEnabled(defaults);
  }

  void _persist(Set<WeatherLayer> enabled) {
    _settings.put(_key, enabled.map((e) => e.name).toList());
  }

  void _persistOpacity(Map<WeatherLayer, double> opacity) {
    _settings.put(
      _opacityKey,
      opacity.map((k, v) => MapEntry(k.name, v)),
    );
  }

  void _persistOrder(List<WeatherLayer> order) {
    _settings.put(_orderKey, order.map((e) => e.name).toList());
  }

  static List<WeatherLayer> _normalizeOrder(List<WeatherLayer> existing, Set<WeatherLayer> enabled) {
    final out = <WeatherLayer>[];
    for (final l in existing) {
      if (enabled.contains(l) && !out.contains(l)) out.add(l);
    }
    for (final l in enabled) {
      if (!out.contains(l)) out.add(l);
    }
    return out;
  }

  static List<WeatherLayer> _loadOrder(SettingsRepository settings, Set<WeatherLayer> enabled) {
    final raw = settings.get<Object?>(_orderKey);
    if (raw is List) {
      final out = <WeatherLayer>[];
      for (final v in raw) {
        final name = v?.toString();
        if (name == null) continue;
        final match = WeatherLayer.values.where((e) => e.name == name);
        if (match.isEmpty) continue;
        out.add(match.first);
      }
      return _normalizeOrder(out, enabled);
    }
    return _normalizeOrder(WeatherLayer.values.toList(), enabled);
  }

  static Map<WeatherLayer, double> _loadOpacity(SettingsRepository settings) {
    final raw = settings.get<Object?>(_opacityKey);
    if (raw is Map) {
      final out = <WeatherLayer, double>{};
      for (final entry in raw.entries) {
        final key = entry.key;
        final value = entry.value;
        final name = key?.toString();
        if (name == null || value is! num) continue;
        final match = WeatherLayer.values.where((e) => e.name == name);
        if (match.isEmpty) continue;
        out[match.first] = value.toDouble().clamp(0.0, maxOpacity);
      }
      return out;
    }

    return {
      WeatherLayer.radar: 0.65,
      WeatherLayer.wind: maxOpacity,
      WeatherLayer.temperature: maxOpacity,
    };
  }

  static Set<WeatherLayer> load(SettingsRepository settings, UserProfile profile) {
    final raw = settings.get<Object?>(_key);
    if (raw is List) {
      final enabled = <WeatherLayer>{};
      for (final v in raw) {
        final name = v?.toString();
        if (name == null) continue;
        final match = WeatherLayer.values.where((e) => e.name == name);
        if (match.isEmpty) continue;
        enabled.add(match.first);
      }
      return enabled.length <= maxEnabled ? enabled : enabled.take(maxEnabled).toSet();
    }

    // fallback to profile defaults
    final defaults = <WeatherLayer>{};
    for (final l in profile.defaultLayers) {
      switch (l) {
        case 'precipitation':
          defaults.add(WeatherLayer.radar);
        case 'wind':
          defaults.add(WeatherLayer.wind);
        case 'temp':
          defaults.add(WeatherLayer.temperature);
        default:
          break;
      }
    }
    return defaults.length <= maxEnabled ? defaults : defaults.take(maxEnabled).toSet();
  }
}

final weatherLayersProvider = StateNotifierProvider.autoDispose<WeatherLayersNotifier, WeatherLayersState>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  final profile = ref.watch(profileNotifierProvider);
  final initial = WeatherLayersNotifier.load(settings, profile);
  return WeatherLayersNotifier(settings, initial);
});
