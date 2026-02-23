import 'package:weathernav/domain/models/offline_zone.dart';
import 'package:weathernav/domain/repositories/offline_zones_repository.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/core/storage/settings_keys.dart';

class OfflineZonesRepositoryImpl implements OfflineZonesRepository {
  OfflineZonesRepositoryImpl(this._settings);

  final SettingsRepository _settings;

  @override
  List<OfflineZone> read() {
    return _decode(_settings.get<Object?>(SettingsKeys.offlineZones));
  }

  @override
  Stream<List<OfflineZone>> watch() {
    return _settings.watch(SettingsKeys.offlineZones).map((_) => read());
  }

  @override
  Future<void> save(List<OfflineZone> zones) {
    final payload = zones.map(_encode).toList();
    return _settings.put(SettingsKeys.offlineZones, payload);
  }
}

Map<String, Object?> _encode(OfflineZone z) {
  return {
    'id': z.id,
    'name': z.name,
    'lat': z.lat,
    'lng': z.lng,
    'radiusKm': z.radiusKm,
    'createdAtMs': z.createdAt.millisecondsSinceEpoch,
  };
}

List<OfflineZone> _decode(Object? raw) {
  if (raw is! List) return const <OfflineZone>[];
  final out = <OfflineZone>[];
  for (final item in raw) {
    final z = _decodeOne(item);
    if (z != null) out.add(z);
  }
  return out;
}

OfflineZone? _decodeOne(Object? raw) {
  if (raw is! Map) return null;
  final m = Map<String, Object?>.from(raw as Map);
  final id = m['id']?.toString();
  final name = m['name']?.toString();
  final lat = m['lat'];
  final lng = m['lng'];
  final radius = m['radiusKm'];
  final createdMs = m['createdAtMs'];

  if (id == null ||
      name == null ||
      lat is! num ||
      lng is! num ||
      radius is! num ||
      createdMs is! num) {
    return null;
  }

  return OfflineZone(
    id: id,
    name: name,
    lat: lat.toDouble(),
    lng: lng.toDouble(),
    radiusKm: radius.toDouble(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdMs.toInt()),
  );
}
