/// Represents an offline geographical zone with weather monitoring capabilities.
/// 
/// This immutable model defines a circular area on Earth's surface
/// where weather data can be cached for offline access.
/// 
/// The zone is defined by a center point (latitude/longitude) and a radius.
/// Each zone has a unique identifier and creation timestamp for tracking.
class OfflineZone {
  /// Creates a new [OfflineZone] with the specified parameters.
  /// 
  /// All parameters are required and validated:
  /// - [id]: Unique identifier for the zone
  /// - [name]: Human-readable name (max 100 characters)
  /// - [lat]: Latitude in decimal degrees (-90 to 90)
  /// - [lng]: Longitude in decimal degrees (-180 to 180)
  /// - [radiusKm]: Radius in kilometers (0 to 1000)
  /// - [createdAt]: When this zone was created
  const OfflineZone({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.radiusKm,
    required this.createdAt,
  }) : _validated = true;

  /// Internal constructor for validation
  const OfflineZone._internal({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.radiusKm,
    required this.createdAt,
  }) : _validated = false;

  /// Unique identifier for this zone
  /// Generated using timestamp and random number for uniqueness
  final String id;

  /// Human-readable name for this zone
  /// Must be non-empty and max 100 characters
  final String name;

  /// Latitude of the zone center in decimal degrees
  /// Range: -90.0 to 90.0
  final double lat;

  /// Longitude of the zone center in decimal degrees
  /// Range: -180.0 to 180.0
  final double lng;

  /// Radius of the zone in kilometers
  /// Range: 0.0 to 1000.0
  final double radiusKm;

  /// When this zone was created
  /// Used for sorting and tracking purposes
  final DateTime createdAt;

  /// Internal flag to track if this instance was validated
  final bool _validated;

  /// Validates the zone data and returns a new instance if valid
  /// 
  /// Returns null if any validation fails
  static OfflineZone? validated({
    required String id,
    required String name,
    required double lat,
    required double lng,
    required double radiusKm,
    required DateTime createdAt,
  }) {
    if (id.isEmpty) return null;
    if (name.trim().isEmpty) return null;
    if (name.length > 100) return null;
    if (lat.isNaN || lng.isNaN || radiusKm.isNaN) return null;
    if (lat < -90 || lat > 90) return null;
    if (lng < -180 || lng > 180) return null;
    if (radiusKm <= 0 || radiusKm > 1000) return null;
    
    return OfflineZone(
      id: id,
      name: name.trim(),
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      createdAt: createdAt,
    );
  }

  /// Creates a copy of this zone with updated values
  /// 
  /// Any parameter that is null will use the current value
  OfflineZone copyWith({
    String? id,
    String? name,
    double? lat,
    double? lng,
    double? radiusKm,
    DateTime? createdAt,
  }) {
    return OfflineZone(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radiusKm: radiusKm ?? this.radiusKm,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Calculates the approximate area of this zone in square kilometers
  /// 
  /// Uses the formula: π × r² where r is the radius
  double get areaKm2 => 3.14159 * radiusKm * radiusKm;

  /// Returns true if this zone contains the specified coordinates
  /// 
  /// Uses the Haversine formula to calculate great-circle distance
  /// between the zone center and the specified point
  bool contains(double lat, double lng) {
    const earthRadiusKm = 6371;
    
    final dLat = _toRadians(this.lat - lat);
    final dLng = _toRadians(this.lng - lng);
    
    final double a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        _toRadians(lat).cos() * _toRadians(this.lat).cos() *
        (dLng / 2).sin() * (dLng / 2).sin();
    
    final c = 2 * a.sqrt().asin();
    final distance = earthRadiusKm * c;
    
    return distance <= radiusKm;
  }

  /// Converts degrees to radians
  double _toRadians(double degrees) => degrees * (3.14159 / 180.0);

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

  @override
  String toString() {
    return 'OfflineZone(id: $id, name: $name, lat: $lat, lng: $lng, radiusKm: $radiusKm, createdAt: $createdAt)';
  }

  /// Returns a JSON-serializable map representation of this zone
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'radiusKm': radiusKm,
      'createdAtMs': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Creates an [OfflineZone] from a JSON map
  /// 
  /// Returns null if the data is invalid
  static OfflineZone? fromJson(Map<String, Object?> json) {
    final id = json['id']?.toString();
    final name = json['name']?.toString();
    final lat = json['lat'];
    final lng = json['lng'];
    final radiusKm = json['radiusKm'];
    final createdAtMs = json['createdAtMs'];
    
    if (id == null || name == null || lat is! num || lng is! num || 
        radiusKm is! num || createdAtMs is! num) {
      return null;
    }
    
    return OfflineZone.validated(
      id: id,
      name: name,
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      radiusKm: radiusKm.toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs.toInt()),
    );
  }
}
