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

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OfflineZone &&
            other.id == id &&
            other.name == name &&
            other.lat == lat &&
            other.lng == lng &&
            other.radiusKm == radiusKm &&
            other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, name, lat, lng, radiusKm, createdAt);
}
