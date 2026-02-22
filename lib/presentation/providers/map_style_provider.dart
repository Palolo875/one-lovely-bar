import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';

enum MapStyleSource {
  openFreeMap,
  cartoPositron,
  stamenToner,
}

class MapStyleState {

  const MapStyleState({required this.source});
  final MapStyleSource source;

  String get styleUrl {
    switch (source) {
      case MapStyleSource.openFreeMap:
        return 'https://tiles.openfreemap.org/styles/positron';
      case MapStyleSource.cartoPositron:
        return 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json';
      case MapStyleSource.stamenToner:
        return 'https://tiles.stadiamaps.com/styles/stamen_toner.json';
    }
  }

  MapStyleState copyWith({MapStyleSource? source}) {
    return MapStyleState(source: source ?? this.source);
  }
}

class MapStyleNotifier extends StateNotifier<MapStyleState> {

  MapStyleNotifier(this._settings)
      : super(
          MapStyleState(source: _read(_settings)),
        );
  final SettingsRepository _settings;

  static const _key = 'map_style_source';

  static MapStyleSource _read(SettingsRepository settings) {
    final raw = settings.getOrDefault<String>(_key, 'openfreemap');
    if (raw == 'carto') return MapStyleSource.cartoPositron;
    if (raw == 'stamen') return MapStyleSource.stamenToner;
    return MapStyleSource.openFreeMap;
  }

  void setSource(MapStyleSource src) {
    state = state.copyWith(source: src);
    _settings.put(
      _key,
      switch (src) {
        MapStyleSource.cartoPositron => 'carto',
        MapStyleSource.stamenToner => 'stamen',
        _ => 'openfreemap',
      },
    );
  }
}

final mapStyleProvider = StateNotifierProvider.autoDispose<MapStyleNotifier, MapStyleState>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return MapStyleNotifier(settings);
});
