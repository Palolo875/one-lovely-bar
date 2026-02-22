enum PoiCategory {
  shelter,
  hut,
  weatherStation,
  port,
}

class Poi {

  const Poi({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
  });
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final PoiCategory category;
}
