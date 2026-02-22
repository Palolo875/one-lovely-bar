import 'package:weathernav/domain/models/place_suggestion.dart';

abstract class GeocodingRepository {
  Future<List<PlaceSuggestion>> search(String query, {int limit = 8});
}
