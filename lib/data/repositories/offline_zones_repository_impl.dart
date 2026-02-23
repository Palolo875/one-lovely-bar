import 'package:weathernav/domain/models/offline_zone.dart';
import 'package:weathernav/domain/repositories/offline_zones_repository.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/core/storage/settings_keys.dart';
import 'package:weathernav/core/logging/app_logger.dart';

/// Implementation of [OfflineZonesRepository] that handles persistence
/// through a [SettingsRepository] with robust error handling and validation.
class OfflineZonesRepositoryImpl implements OfflineZonesRepository {
  const OfflineZonesRepositoryImpl(this._settings);

  final SettingsRepository _settings;

  @override
  List<OfflineZone> read() {
    try {
      final raw = _settings.get<Object?>(SettingsKeys.offlineZones);
      return _decode(raw);
    } catch (e, st) {
      AppLogger.error('Failed to read offline zones from storage', 
          name: 'OfflineZonesRepositoryImpl', error: e, stackTrace: st);
      return const <OfflineZone>[];
    }
  }

  @override
  Stream<List<OfflineZone>> watch() {
    try {
      return _settings
          .watch(SettingsKeys.offlineZones)
          .map((_) => read())
          .handleError((e, st) {
            AppLogger.error('Error in offline zones watch stream', 
                name: 'OfflineZonesRepositoryImpl', error: e, stackTrace: st);
            return <OfflineZone>[];
          });
    } catch (e, st) {
      AppLogger.error('Failed to setup offline zones watch stream', 
          name: 'OfflineZonesRepositoryImpl', error: e, stackTrace: st);
      return Stream.value(const <OfflineZone>[]);
    }
  }

  @override
  Future<void> save(List<OfflineZone> zones) async {
    try {
      if (zones.length > 1000) {
        throw ArgumentError('Too many zones (${zones.length}). Maximum allowed is 1000.');
      }
      
      final payload = zones.map(_encode).toList();
      await _settings.put(SettingsKeys.offlineZones, payload);
      
      AppLogger.info('Successfully saved ${zones.length} offline zones', 
          name: 'OfflineZonesRepositoryImpl');
    } catch (e, st) {
      AppLogger.error('Failed to save offline zones to storage', 
          name: 'OfflineZonesRepositoryImpl', error: e, stackTrace: st);
      rethrow;
    }
  }
}

/// Encodes an [OfflineZone] into a serializable Map<String, Object?>.
/// 
/// This method handles the conversion of domain objects to a format
/// suitable for persistence in settings storage.
/// 
/// Throws [ArgumentError] if the zone data is invalid.
Map<String, Object?> _encode(OfflineZone zone) {
  try {
    if (zone.id.isEmpty) {
      throw ArgumentError('Zone ID cannot be empty');
    }
    if (zone.name.trim().isEmpty) {
      throw ArgumentError('Zone name cannot be empty');
    }
    if (zone.name.length > 100) {
      throw ArgumentError('Zone name too long (max 100 characters)');
    }
    if (zone.lat.isNaN || zone.lng.isNaN || zone.radiusKm.isNaN) {
      throw ArgumentError('Zone coordinates or radius cannot be NaN');
    }
    if (zone.lat < -90 || zone.lat > 90) {
      throw ArgumentError('Zone latitude must be between -90 and 90');
    }
    if (zone.lng < -180 || zone.lng > 180) {
      throw ArgumentError('Zone longitude must be between -180 and 180');
    }
    if (zone.radiusKm <= 0 || zone.radiusKm > 1000) {
      throw ArgumentError('Zone radius must be between 0 and 1000 km');
    }
    
    return {
      'id': zone.id,
      'name': zone.name.trim(),
      'lat': zone.lat,
      'lng': zone.lng,
      'radiusKm': zone.radiusKm,
      'createdAtMs': zone.createdAt.millisecondsSinceEpoch,
    };
  } catch (e) {
    AppLogger.error('Failed to encode offline zone: ${zone.id}', 
        name: '_encode', error: e);
    rethrow;
  }
}

/// Decodes raw storage data into a list of [OfflineZone] objects.
/// 
/// Handles various data formats and provides robust error recovery.
/// Invalid entries are skipped rather than failing the entire operation.
/// 
/// [raw] - The raw data from storage, expected to be a List
/// Returns a list of valid [OfflineZone] objects, empty list if decoding fails
List<OfflineZone> _decode(Object? raw) {
  if (raw == null) {
    AppLogger.debug('No offline zones data found in storage', name: '_decode');
    return const <OfflineZone>[];
  }
  
  if (raw is! List) {
    AppLogger.warning('Invalid offline zones data format: expected List, got ${raw.runtimeType}', 
        name: '_decode');
    return const <OfflineZone>[];
  }
  
  final zones = <OfflineZone>[];
  var invalidCount = 0;
  
  for (var i = 0; i < raw.length; i++) {
    try {
      final zone = _decodeOne(raw[i]);
      if (zone != null) {
        zones.add(zone);
      } else {
        invalidCount++;
        AppLogger.warning('Invalid offline zone data at index $i', name: '_decode');
      }
    } catch (e, st) {
      invalidCount++;
      AppLogger.error('Error decoding offline zone at index $i', 
          name: '_decode', error: e, stackTrace: st);
    }
  }
  
  if (invalidCount > 0) {
    AppLogger.warning('Skipped $invalidCount invalid offline zone entries during decoding', 
        name: '_decode');
  }
  
  AppLogger.debug('Successfully decoded ${zones.length} offline zones', name: '_decode');
  return zones;
}

/// Decodes a single offline zone from raw storage data.
/// 
/// Performs comprehensive validation of the decoded data.
/// Returns null if the data is invalid or cannot be decoded.
/// 
/// [raw] - The raw zone data, expected to be a Map
/// Returns a valid [OfflineZone] or null if decoding fails
OfflineZone? _decodeOne(Object? raw) {
  if (raw == null) {
    return null;
  }
  
  if (raw is! Map) {
    return null;
  }
  
  try {
    final Map<String, Object?> data;
    if (raw is Map<String, Object?>) {
      data = raw;
    } else {
      data = Map<String, Object?>.from(raw);
    }
    
    final id = data['id']?.toString();
    final name = data['name']?.toString();
    final lat = data['lat'];
    final lng = data['lng'];
    final radius = data['radiusKm'];
    final createdMs = data['createdAtMs'];
    
    // Validate required fields
    if (id == null || id.isEmpty) {
      return null;
    }
    if (name == null || name.trim().isEmpty) {
      return null;
    }
    if (name.length > 100) {
      return null;
    }
    if (lat is! num || lat.isNaN) {
      return null;
    }
    if (lng is! num || lng.isNaN) {
      return null;
    }
    if (radius is! num || radius.isNaN) {
      return null;
    }
    if (createdMs is! num) {
      return null;
    }
    
    final latDouble = lat.toDouble();
    final lngDouble = lng.toDouble();
    final radiusDouble = radius.toDouble();
    final createdMsInt = createdMs.toInt();
    
    // Validate coordinate ranges
    if (latDouble < -90 || latDouble > 90) {
      return null;
    }
    if (lngDouble < -180 || lngDouble > 180) {
      return null;
    }
    if (radiusDouble <= 0 || radiusDouble > 1000) {
      return null;
    }
    
    // Validate timestamp
    final now = DateTime.now().millisecondsSinceEpoch;
    if (createdMsInt > now || createdMsInt < 0) {
      return null;
    }
    
    return OfflineZone(
      id: id,
      name: name.trim(),
      lat: latDouble,
      lng: lngDouble,
      radiusKm: radiusDouble,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdMsInt),
    );
  } catch (e, st) {
    AppLogger.error('Unexpected error decoding offline zone', 
        name: '_decodeOne', error: e, stackTrace: st);
    return null;
  }
}
