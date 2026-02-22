import 'package:weathernav/core/storage/local_database.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/models/trip_history_item.dart';
import 'package:weathernav/domain/repositories/trip_history_repository.dart';
import 'package:sqlite3/sqlite3.dart' show Row;

TripHistoryRepository createTripHistoryRepository() => TripHistoryRepositoryImplIo();

class TripHistoryRepositoryImplIo implements TripHistoryRepository {
  @override
  Future<void> addTrip({
    required DateTime createdAt,
    required String profile, required double startLat, required double startLng, required double endLat, required double endLng, required double distanceKm, required double durationMinutes, DateTime? departureTime,
    String? gpx,
  }) async {
    try {
      final db = await LocalDatabase.instance.open();
      db.execute('BEGIN IMMEDIATE;');
      try {
        db.execute(
          'INSERT INTO trips (created_at_ms, departure_time_ms, profile, start_lat, start_lng, end_lat, end_lng, distance_km, duration_minutes, gpx) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            createdAt.millisecondsSinceEpoch,
            departureTime?.millisecondsSinceEpoch,
            profile,
            startLat,
            startLng,
            endLat,
            endLng,
            distanceKm,
            durationMinutes,
            gpx,
          ],
        );
        db.execute('COMMIT;');
      } catch (_) {
        db.execute('ROLLBACK;');
        rethrow;
      }
    } catch (e, st) {
      throw AppFailure("Impossible d'enregistrer le trajet.", cause: e, stackTrace: st);
    }
  }

  @override
  Future<TripHistoryItem?> getTrip(int id) async {
    try {
      final db = await LocalDatabase.instance.open();
      final rs = db.select('SELECT * FROM trips WHERE id = ? LIMIT 1', [id]);
      if (rs.isEmpty) return null;
      return _mapRow(rs.first);
    } catch (e, st) {
      throw AppFailure('Impossible de charger le trajet.', cause: e, stackTrace: st);
    }
  }

  @override
  Future<List<TripHistoryItem>> listTrips({int limit = 50}) async {
    try {
      final db = await LocalDatabase.instance.open();
      final safeLimit = limit.clamp(1, 500);
      final rs = db.select('SELECT * FROM trips ORDER BY created_at_ms DESC LIMIT ?', [safeLimit]);
      return rs.map(_mapRow).toList();
    } catch (e, st) {
      throw AppFailure("Impossible de charger l'historique.", cause: e, stackTrace: st);
    }
  }

  TripHistoryItem _mapRow(Row row) {
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
