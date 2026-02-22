import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';

class OfflineZone {

  const OfflineZone({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.radiusKm,
    required this.createdAt,
  });
  final String id;
  final String name;
  final double lat;
  final double lng;
  final double radiusKm;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'radiusKm': radiusKm,
      'createdAtMs': createdAt.millisecondsSinceEpoch,
    };
  }

  static OfflineZone? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, Object?>.from(raw as Map);
    final id = m['id']?.toString();
    final name = m['name']?.toString();
    final lat = m['lat'];
    final lng = m['lng'];
    final radius = m['radiusKm'];
    final createdMs = m['createdAtMs'];
    if (id == null || name == null || lat is! num || lng is! num || radius is! num || createdMs is! int) {
      return null;
    }
    return OfflineZone(
      id: id,
      name: name,
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      radiusKm: radius.toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdMs),
    );
  }
}

class OfflineZonesNotifier extends StateNotifier<List<OfflineZone>> {

  OfflineZonesNotifier(this._settings) : super(_read(_settings));
  final SettingsRepository _settings;

  static const _key = 'offline_zones';

  static List<OfflineZone> _read(SettingsRepository settings) {
    final raw = settings.get<Object?>(_key);
    if (raw is List) {
      final out = <OfflineZone>[];
      for (final r in raw) {
        final z = OfflineZone.fromMap(r);
        if (z != null) out.add(z);
      }
      return out;
    }
    return const <OfflineZone>[];
  }

  Future<void> _persist(List<OfflineZone> list) async {
    await _settings.put(_key, list.map((z) => z.toMap()).toList());
  }

  void add({required String name, required double lat, required double lng, required double radiusKm}) {
    final id = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';
    final next = [
      OfflineZone(
        id: id,
        name: name,
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        createdAt: DateTime.now(),
      ),
      ...state,
    ];
    state = next;
    unawaited(_persist(next));
  }

  void remove(String id) {
    final next = state.where((z) => z.id != id).toList();
    state = next;
    unawaited(_persist(next));
  }
}

final offlineZonesProvider = StateNotifierProvider.autoDispose<OfflineZonesNotifier, List<OfflineZone>>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return OfflineZonesNotifier(settings);
});
