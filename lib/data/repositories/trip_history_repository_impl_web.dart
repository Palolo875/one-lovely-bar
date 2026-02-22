import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/models/trip_history_item.dart';
import 'package:weathernav/domain/repositories/trip_history_repository.dart';

TripHistoryRepository createTripHistoryRepository() => TripHistoryRepositoryImplWeb();

class TripHistoryRepositoryImplWeb implements TripHistoryRepository {
  static const _boxName = 'trips';

  Box get _box {
    if (!Hive.isBoxOpen(_boxName)) {
      throw StateError('Hive box "$_boxName" is not open. Call Hive.openBox("$_boxName") at startup.');
    }
    return Hive.box(_boxName);
  }

  int _nextId() {
    var maxId = 0;
    for (final k in _box.keys) {
      if (k is int && k > maxId) maxId = k;
    }
    return maxId + 1;
  }

  @override
  Future<void> addTrip({
    required DateTime createdAt,
    required String profile, required double startLat, required double startLng, required double endLat, required double endLng, required double distanceKm, required double durationMinutes, DateTime? departureTime,
    String? gpx,
  }) async {
    try {
      final id = _nextId();
      await _box.put(id, {
        'id': id,
        'created_at_ms': createdAt.millisecondsSinceEpoch,
        'departure_time_ms': departureTime?.millisecondsSinceEpoch,
        'profile': profile,
        'start_lat': startLat,
        'start_lng': startLng,
        'end_lat': endLat,
        'end_lng': endLng,
        'distance_km': distanceKm,
        'duration_minutes': durationMinutes,
        'gpx': gpx,
      });
    } catch (e, st) {
      throw AppFailure("Impossible d'enregistrer le trajet.", cause: e, stackTrace: st);
    }
  }

  @override
  Future<TripHistoryItem?> getTrip(int id) async {
    try {
      final raw = _box.get(id);
      if (raw is! Map) return null;
      return _mapMap(raw);
    } catch (e, st) {
      throw AppFailure('Impossible de charger le trajet.', cause: e, stackTrace: st);
    }
  }

  @override
  Future<List<TripHistoryItem>> listTrips({int limit = 50}) async {
    try {
      final out = <TripHistoryItem>[];
      for (final k in _box.keys) {
        if (k is! int) continue;
        final raw = _box.get(k);
        if (raw is! Map) continue;
        out.add(_mapMap(raw));
      }
      out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (out.length > limit) return out.sublist(0, limit);
      return out;
    } catch (e, st) {
      throw AppFailure("Impossible de charger l'historique.", cause: e, stackTrace: st);
    }
  }

  TripHistoryItem _mapMap(Map row) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(row['created_at_ms'] as int);
    final departureMs = row['departure_time_ms'] as int?;

    return TripHistoryItem(
      id: row['id'] as int,
      createdAt: createdAt,
      departureTime: departureMs == null ? null : DateTime.fromMillisecondsSinceEpoch(departureMs),
      profile: row['profile'] as String,
      startLat: (row['start_lat'] as num).toDouble(),
      startLng: (row['start_lng'] as num).toDouble(),
      endLat: (row['end_lat'] as num).toDouble(),
      endLng: (row['end_lng'] as num).toDouble(),
      distanceKm: (row['distance_km'] as num).toDouble(),
      durationMinutes: (row['duration_minutes'] as num).toDouble(),
      gpx: row['gpx'] as String?,
    );
  }
}
