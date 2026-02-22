import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/settings_repository.dart';
import 'settings_repository_provider.dart';

class OfflineZone {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final double radiusKm;
  final DateTime createdAt;

  const OfflineZone({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.radiusKm,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'radiusKm': radiusKm,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  static OfflineZone? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = m['id']?.toString();
    final name = m['name']?.toString();
    final lat = m['lat'];
    final lng = m['lng'];
    final radiusKm = m['radiusKm'];
    final createdAt = m['createdAt'];
    if (id == null || name == null || lat is! num || lng is! num || radiusKm is! num || createdAt is! int) {
      return null;
    }
    return OfflineZone(
      id: id,
      name: name,
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      radiusKm: radiusKm.toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    );
  }
}

class OfflineZonesNotifier extends StateNotifier<List<OfflineZone>> {
  final SettingsRepository _settings;

  OfflineZonesNotifier(this._settings) : super(_read(_settings));

  static const _key = 'offline_zones';

  static List<OfflineZone> _read(SettingsRepository settings) {
    final raw = settings.get<dynamic>(_key);
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

  void _persist(List<OfflineZone> list) {
    _settings.put(_key, list.map((z) => z.toMap()).toList());
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
    _persist(next);
  }

  void remove(String id) {
    final next = state.where((z) => z.id != id).toList();
    state = next;
    _persist(next);
  }
}

final offlineZonesProvider = StateNotifierProvider.autoDispose<OfflineZonesNotifier, List<OfflineZone>>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return OfflineZonesNotifier(settings);
});
