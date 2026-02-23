import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernav/core/logging/app_logger.dart';
import 'package:weathernav/core/storage/settings_keys.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/presentation/providers/profile_provider.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';

enum WeatherLayer { radar, wind, temperature }

class WeatherLayersState {
  const WeatherLayersState({
    required this.enabled,
    required this.order,
    required this.opacity,
  });
  final Set<WeatherLayer> enabled;
  final List<WeatherLayer> order;
  final Map<WeatherLayer, double> opacity;

  WeatherLayersState copyWith({
    Set<WeatherLayer>? enabled,
    List<WeatherLayer>? order,
    Map<WeatherLayer, double>? opacity,
  }) {
    return WeatherLayersState(
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
      opacity: opacity ?? this.opacity,
    );
  }
}

class WeatherLayersNotifier extends Notifier<WeatherLayersState> {
  late final SettingsRepository _settings;
  late final bool _hasExplicitSelection;

  final List<StreamSubscription> _subs = [];
  Timer? _persistDebounce;
  WeatherLayersState? _pendingPersist;

  static const int maxEnabled = 3;
  static const double maxOpacity = 0.70;

  @override
  WeatherLayersState build() {
    _settings = ref.watch(settingsRepositoryProvider);
    final profile = ref.watch(profileProvider);
    final raw = _settings.get<Object?>(SettingsKeys.enabledWeatherLayers);
    _hasExplicitSelection = raw is List;

    final initial = load(_settings, profile);
    final initialState = WeatherLayersState(
      enabled: initial,
      order: _loadOrder(_settings, initial),
      opacity: _loadOpacity(_settings),
    );

    var syncScheduled = false;
    void sync() {
      final enabled = _loadEnabled(_settings);
      final next = WeatherLayersState(
        enabled: enabled.isNotEmpty ? enabled : state.enabled,
        order: _loadOrder(
          _settings,
          enabled.isNotEmpty ? enabled : state.enabled,
        ),
        opacity: _loadOpacity(_settings),
      );
      if (!_same(next, state)) state = next;
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
      SettingsKeys.enabledWeatherLayers,
      SettingsKeys.weatherLayerOpacity,
      SettingsKeys.weatherLayerOrder,
    ]) {
      _subs.add(_settings.watch(key).listen((_) => scheduleSync()));
    }

    ref.onDispose(() {
      _persistDebounce?.cancel();
      _persistDebounce = null;
      for (final sub in _subs) {
        sub.cancel();
      }
      _subs.clear();
    });

    return initialState;
  }

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
    _schedulePersist(state);
  }

  void setEnabled(Set<WeatherLayer> enabled) {
    final next = enabled.length <= maxEnabled
        ? enabled
        : enabled.take(maxEnabled).toSet();
    final nextOrder = _normalizeOrder(state.order, next);
    state = state.copyWith(enabled: next, order: nextOrder);
    _schedulePersist(state);
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
    _schedulePersist(state);
  }

  void setOpacity(WeatherLayer layer, double value) {
    final next = Map<WeatherLayer, double>.from(state.opacity);
    next[layer] = value.clamp(0.0, maxOpacity);
    state = state.copyWith(opacity: next);
    _schedulePersist(state);
  }

  void resetToProfile(UserProfile profile) {
    setEnabled(_layersFromProfile(profile));
  }

  void applyProfileDefaultsIfUnset(UserProfile profile) {
    if (_hasExplicitSelection) return;
    final nextEnabled = _layersFromProfile(profile);
    final nextOrder = _normalizeOrder(state.order, nextEnabled);
    state = state.copyWith(enabled: nextEnabled, order: nextOrder);
    _schedulePersist(state);
  }

  void _schedulePersist(WeatherLayersState snapshot) {
    _pendingPersist = snapshot;
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 250), () {
      final toPersist = _pendingPersist;
      if (toPersist == null) return;
      _pendingPersist = null;
      unawaited(_persistNow(toPersist));
    });
  }

  Future<void> _persistNow(WeatherLayersState snapshot) async {
    try {
      await _settings.put(
        SettingsKeys.enabledWeatherLayers,
        snapshot.enabled.map((e) => e.name).toList(),
      );
      await _settings.put(
        SettingsKeys.weatherLayerOrder,
        snapshot.order.map((e) => e.name).toList(),
      );
      await _settings.put(
        SettingsKeys.weatherLayerOpacity,
        snapshot.opacity.map((k, v) => MapEntry(k.name, v)),
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to persist weather layers settings',
        name: 'settings',
        error: e,
        stackTrace: st,
      );
      final enabled = _loadEnabled(_settings);
      final recovered = WeatherLayersState(
        enabled: enabled.isNotEmpty ? enabled : state.enabled,
        order: _loadOrder(
          _settings,
          enabled.isNotEmpty ? enabled : state.enabled,
        ),
        opacity: _loadOpacity(_settings),
      );
      if (!_same(recovered, state)) state = recovered;
    }
  }

  static bool _same(WeatherLayersState a, WeatherLayersState b) {
    if (identical(a, b)) return true;
    if (a.enabled.length != b.enabled.length) return false;
    if (a.order.length != b.order.length) return false;
    if (a.opacity.length != b.opacity.length) return false;
    for (final l in a.enabled) {
      if (!b.enabled.contains(l)) return false;
    }
    for (var i = 0; i < a.order.length; i++) {
      if (a.order[i] != b.order[i]) return false;
    }
    for (final e in a.opacity.entries) {
      final other = b.opacity[e.key];
      if (other == null || other != e.value) return false;
    }
    return true;
  }

  static List<WeatherLayer> _normalizeOrder(
    List<WeatherLayer> existing,
    Set<WeatherLayer> enabled,
  ) {
    final out = <WeatherLayer>[];
    for (final l in existing) {
      if (enabled.contains(l) && !out.contains(l)) out.add(l);
    }
    for (final l in WeatherLayer.values) {
      if (enabled.contains(l) && !out.contains(l)) out.add(l);
    }
    return out;
  }

  static List<WeatherLayer> _loadOrder(
    SettingsRepository settings,
    Set<WeatherLayer> enabled,
  ) {
    final raw = settings.get<Object?>(SettingsKeys.weatherLayerOrder);
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
    final raw = settings.get<Object?>(SettingsKeys.weatherLayerOpacity);
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
      for (final e in const {
        WeatherLayer.radar: 0.65,
        WeatherLayer.wind: maxOpacity,
        WeatherLayer.temperature: maxOpacity,
      }.entries) {
        out.putIfAbsent(e.key, () => e.value);
      }
      return out;
    }

    return const {
      WeatherLayer.radar: 0.65,
      WeatherLayer.wind: maxOpacity,
      WeatherLayer.temperature: maxOpacity,
    };
  }

  static Set<WeatherLayer> _loadEnabled(SettingsRepository settings) {
    final raw = settings.get<Object?>(SettingsKeys.enabledWeatherLayers);
    if (raw is List) {
      final enabled = <WeatherLayer>{};
      for (final v in raw) {
        final name = v?.toString();
        if (name == null) continue;
        final match = WeatherLayer.values.where((e) => e.name == name);
        if (match.isEmpty) continue;
        enabled.add(match.first);
      }
      return enabled.length <= maxEnabled
          ? enabled
          : enabled.take(maxEnabled).toSet();
    }

    return const <WeatherLayer>{};
  }

  static Set<WeatherLayer> load(
    SettingsRepository settings,
    UserProfile profile,
  ) {
    final enabled = _loadEnabled(settings);
    if (enabled.isNotEmpty) {
      return enabled.length <= maxEnabled
          ? enabled
          : enabled.take(maxEnabled).toSet();
    }

    // fallback to profile defaults
    final defaults = <WeatherLayer>{};
    for (final l in profile.defaultLayers) {
      final mapped = _fromProfileLayerKey(l);
      if (mapped != null) defaults.add(mapped);
    }
    return defaults.length <= maxEnabled
        ? defaults
        : defaults.take(maxEnabled).toSet();
  }

  static WeatherLayer? _fromProfileLayerKey(String key) {
    return switch (key) {
      'precipitation' => WeatherLayer.radar,
      'wind' => WeatherLayer.wind,
      'temp' => WeatherLayer.temperature,
      _ => null,
    };
  }

  static Set<WeatherLayer> _layersFromProfile(UserProfile profile) {
    final out = <WeatherLayer>{};
    for (final l in profile.defaultLayers) {
      final mapped = _fromProfileLayerKey(l);
      if (mapped != null) out.add(mapped);
    }
    return out.length <= maxEnabled ? out : out.take(maxEnabled).toSet();
  }
}

final weatherLayersProvider =
    NotifierProvider<WeatherLayersNotifier, WeatherLayersState>(
      WeatherLayersNotifier.new,
    );
