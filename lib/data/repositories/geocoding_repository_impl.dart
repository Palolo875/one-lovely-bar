import 'package:dio/dio.dart';
import 'package:weathernav/core/config/app_config.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/models/place_suggestion.dart';
import 'package:weathernav/domain/repositories/geocoding_repository.dart';

class PhotonGeocodingRepository implements GeocodingRepository {

  PhotonGeocodingRepository(this._dio);
  final Dio _dio;

  Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  List<dynamic>? _asList(dynamic v) {
    if (v is List) return v;
    return null;
  }

  @override
  Future<List<PlaceSuggestion>> search(String query, {int limit = 8}) async {
    if (query.trim().isEmpty) return const <PlaceSuggestion>[];

    late final Response response;
    try {
      response = await _dio.get(
        '${AppConfig.photonBaseUrl}/api/',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );
    } on DioException catch (e, st) {
      throw AppFailure('Impossible de rechercher ce lieu.', cause: e, stackTrace: st);
    } catch (e, st) {
      throw AppFailure('Erreur inattendue lors de la recherche de lieu.', cause: e, stackTrace: st);
    }

    final data = _asMap(response.data);
    if (data == null) return const <PlaceSuggestion>[];
    final features = _asList(data['features']);
    if (features == null) return const <PlaceSuggestion>[];

    final results = <PlaceSuggestion>[];
    for (final f in features) {
      final fm = _asMap(f);
      if (fm == null) continue;
      final geometry = _asMap(fm['geometry']);
      final properties = _asMap(fm['properties']);
      if (geometry == null || properties == null) continue;

      final coords = _asList(geometry['coordinates']);
      if (coords == null || coords.length < 2) continue;

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
