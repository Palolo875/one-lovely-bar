class TripHistoryItem {

  const TripHistoryItem({
    required this.id,
    required this.createdAt,
    required this.departureTime,
    required this.profile,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.distanceKm,
    required this.durationMinutes,
    required this.gpx,
  });
  final int id;
  final DateTime createdAt;
  final DateTime? departureTime;
  final String profile;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final double distanceKm;
  final double durationMinutes;
  final String? gpx;
}
