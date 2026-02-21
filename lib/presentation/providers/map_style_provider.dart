import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

enum MapStyleSource {
  openFreeMap,
  cartoPositron,
  stamenToner,
}

class MapStyleState {
  final MapStyleSource source;

  const MapStyleState({required this.source});

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
  final Box _box;

  MapStyleNotifier(this._box)
      : super(
          MapStyleState(source: _read(_box)),
        );

  static const _key = 'map_style_source';

  static MapStyleSource _read(Box box) {
    final raw = box.get(_key, defaultValue: 'openfreemap');
    if (raw == 'carto') return MapStyleSource.cartoPositron;
    if (raw == 'stamen') return MapStyleSource.stamenToner;
    return MapStyleSource.openFreeMap;
  }

  void setSource(MapStyleSource src) {
    state = state.copyWith(source: src);
    _box.put(
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
  final box = Hive.box('settings');
  return MapStyleNotifier(box);
});
