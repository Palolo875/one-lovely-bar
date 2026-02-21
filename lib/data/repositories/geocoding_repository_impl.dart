import 'package:dio/dio.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/models/place_suggestion.dart';
import '../../domain/repositories/geocoding_repository.dart';

class PhotonGeocodingRepository implements GeocodingRepository {
  final Dio _dio;

  PhotonGeocodingRepository(this._dio);

  @override
  Future<List<PlaceSuggestion>> search(String query, {int limit = 8}) async {
    if (query.trim().isEmpty) return const <PlaceSuggestion>[];

    late final Response response;
    try {
      response = await _dio.get(
        'https://photon.komoot.io/api/',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );
    } on DioException catch (e) {
      throw AppFailure('Impossible de rechercher ce lieu.', cause: e);
    } catch (e) {
      throw AppFailure('Erreur inattendue lors de la recherche de lieu.', cause: e);
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) return const <PlaceSuggestion>[];
    final features = data['features'];
    if (features is! List) return const <PlaceSuggestion>[];

    final results = <PlaceSuggestion>[];
    for (final f in features) {
      if (f is! Map<String, dynamic>) continue;
      final geometry = f['geometry'];
      final properties = f['properties'];
      if (geometry is! Map<String, dynamic> || properties is! Map<String, dynamic>) continue;

      final coords = geometry['coordinates'];
      if (coords is! List || coords.length < 2) continue;

      final lon = coords[0];
      final lat = coords[1];
      if (lon is! num || lat is! num) continue;

      final name = (properties['name'] ?? properties['street'] ?? properties['city'] ?? properties['country'])?.toString();
      if (name == null || name.trim().isEmpty) continue;

      results.add(
        PlaceSuggestion(
          name: name,
          latitude: lat.toDouble(),
          longitude: lon.toDouble(),
          country: properties['country']?.toString(),
          city: properties['city']?.toString(),
          street: properties['street']?.toString(),
          postcode: properties['postcode']?.toString(),
          state: properties['state']?.toString(),
        ),
      );
    }

    return results;
  }
}
