import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weathernav/core/config/app_config.dart';
import 'package:weathernav/core/logging/app_logger.dart';
import 'package:weathernav/core/storage/settings_keys.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';

enum MapStyleSource { openFreeMap, cartoPositron, stamenToner }

class MapStyleState {
  const MapStyleState({required this.source});
  final MapStyleSource source;

  String get styleUrl {
    switch (source) {
      case MapStyleSource.openFreeMap:
        return AppConfig.openFreeMapStyleUrl;
      case MapStyleSource.cartoPositron:
        return AppConfig.cartoPositronStyleUrl;
      case MapStyleSource.stamenToner:
        return AppConfig.stamenTonerStyleUrl;
    }
  }

  MapStyleState copyWith({MapStyleSource? source}) {
    return MapStyleState(source: source ?? this.source);
  }
}

class MapStyleNotifier extends Notifier<MapStyleState> {
  late final SettingsRepository _settings;
  StreamSubscription<void>? _sub;

  @override
  MapStyleState build() {
    _settings = ref.watch(settingsRepositoryProvider);

    var syncScheduled = false;
    void sync() {
      final next = MapStyleState(source: _read(_settings));
      if (next.source != state.source) state = next;
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
        .watch(SettingsKeys.mapStyleSource)
        .listen((_) => scheduleSync());
    ref.onDispose(() {
      _sub?.cancel();
    });

    return MapStyleState(source: _read(_settings));
  }

  static MapStyleSource _read(SettingsRepository settings) {
    final raw = settings.getOrDefault<String>(
      SettingsKeys.mapStyleSource,
      'openfreemap',
    );
    if (raw == 'carto') return MapStyleSource.cartoPositron;
    if (raw == 'stamen') return MapStyleSource.stamenToner;
    return MapStyleSource.openFreeMap;
  }

  Future<void> setSource(MapStyleSource src) async {
    final prev = state;
    try {
      await _settings.put(SettingsKeys.mapStyleSource, switch (src) {
        MapStyleSource.cartoPositron => 'carto',
        MapStyleSource.stamenToner => 'stamen',
        _ => 'openfreemap',
      });
      state = state.copyWith(source: src);
    } catch (e, st) {
      AppLogger.error(
        'Failed to persist map style source',
        name: 'settings',
        error: e,
        stackTrace: st,
      );
      state = prev;
    }
  }
}

final mapStyleProvider = NotifierProvider<MapStyleNotifier, MapStyleState>(
  MapStyleNotifier.new,
);
