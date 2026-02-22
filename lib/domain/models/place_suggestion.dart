class PlaceSuggestion {

  const PlaceSuggestion({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.city,
    this.street,
    this.postcode,
    this.state,
  });
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? city;
  final String? street;
  final String? postcode;
  final String? state;
}
