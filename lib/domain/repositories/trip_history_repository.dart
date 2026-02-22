import 'package:weathernav/domain/models/trip_history_item.dart';

abstract class TripHistoryRepository {
  Future<void> addTrip({
    required DateTime createdAt,
    required String profile, required double startLat, required double startLng, required double endLat, required double endLng, required double distanceKm, required double durationMinutes, DateTime? departureTime,
    String? gpx,
  });

  Future<List<TripHistoryItem>> listTrips({int limit = 50});

  Future<TripHistoryItem?> getTrip(int id);
}
