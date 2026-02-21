import '../models/trip_history_item.dart';

abstract class TripHistoryRepository {
  Future<void> addTrip({
    required DateTime createdAt,
    DateTime? departureTime,
    required String profile,
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required double distanceKm,
    required double durationMinutes,
    String? gpx,
  });

  Future<List<TripHistoryItem>> listTrips({int limit = 50});

  Future<TripHistoryItem?> getTrip(int id);
}
