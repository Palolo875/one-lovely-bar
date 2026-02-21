import 'package:dio/dio.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/models/poi.dart';
import '../../domain/repositories/poi_repository.dart';

class OverpassPoiRepository implements PoiRepository {
  final Dio _dio;

  OverpassPoiRepository(this._dio);

  @override
  Future<List<Poi>> searchAround({
    required double lat,
    required double lng,
    required int radiusMeters,
    required Set<PoiCategory> categories,
    int limit = 50,
  }) async {
    if (categories.isEmpty) return const <Poi>[];

    final query = _buildQuery(lat: lat, lng: lng, radius: radiusMeters, categories: categories, limit: limit);

    late final Response response;
    try {
      response = await _dio.post(
        'https://overpass-api.de/api/interpreter',
        data: query,
        options: Options(
          contentType: Headers.textPlainContentType,
          responseType: ResponseType.json,
        ),
      );
    } on DioException catch (e) {
      throw AppFailure('Impossible de charger les POIs.', cause: e);
    } catch (e) {
      throw AppFailure('Erreur inattendue lors du chargement des POIs.', cause: e);
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) return const <Poi>[];
    final elements = data['elements'];
    if (elements is! List) return const <Poi>[];

    final pois = <Poi>[];
    for (final el in elements) {
      if (el is! Map<String, dynamic>) continue;
      final type = el['type']?.toString();
      final idRaw = el['id'];
      final latRaw = el['lat'];
      final lonRaw = el['lon'];
      if (type == null || idRaw == null || latRaw is! num || lonRaw is! num) continue;

      final tags = el['tags'];
      if (tags is! Map) continue;

      final category = _categoryFromTags(Map<String, dynamic>.from(tags));
      if (category == null || !categories.contains(category)) continue;

      final name = (tags['name'] ?? tags['ref'] ?? 'POI')?.toString() ?? 'POI';

      pois.add(
        Poi(
          id: '$type/$idRaw',
          name: name,
          latitude: latRaw.toDouble(),
          longitude: lonRaw.toDouble(),
          category: category,
        ),
      );

      if (pois.length >= limit) break;
    }

    return pois;
  }

  String _buildQuery({
    required double lat,
    required double lng,
    required int radius,
    required Set<PoiCategory> categories,
    required int limit,
  }) {
    final filters = <String>[];

    if (categories.contains(PoiCategory.shelter)) {
      filters.add('node["amenity"="shelter"](around:$radius,$lat,$lng);');
    }
    if (categories.contains(PoiCategory.hut)) {
      filters.add('node["tourism"="alpine_hut"](around:$radius,$lat,$lng);');
    }
    if (categories.contains(PoiCategory.weatherStation)) {
      filters.add('node["man_made"="monitoring_station"]["monitoring:weather"="yes"](around:$radius,$lat,$lng);');
    }
    if (categories.contains(PoiCategory.port)) {
      filters.add('node["harbour"="yes"](around:$radius,$lat,$lng);');
    }

    // Overpass QL
    return '[out:json][timeout:25];(\n${filters.join('\n')}\n);out body $limit;';
  }

  PoiCategory? _categoryFromTags(Map<String, dynamic> tags) {
    if (tags['amenity'] == 'shelter') return PoiCategory.shelter;
    if (tags['tourism'] == 'alpine_hut') return PoiCategory.hut;
    if (tags['man_made'] == 'monitoring_station' && tags['monitoring:weather'] == 'yes') {
      return PoiCategory.weatherStation;
    }
    if (tags['harbour'] == 'yes') return PoiCategory.port;
    return null;
  }
}
