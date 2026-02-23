import 'package:dio/dio.dart';
import 'package:weathernav/core/config/app_config.dart';
import 'package:weathernav/core/network/dio_error_mapper.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/models/poi.dart';
import 'package:weathernav/domain/repositories/poi_repository.dart';

class OverpassPoiRepository implements PoiRepository {

  OverpassPoiRepository(this._dio);
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
        '${AppConfig.overpassBaseUrl}/api/interpreter',
        data: query,
        options: Options(
          contentType: Headers.textPlainContentType,
          responseType: ResponseType.json,
        ),
      );
    } on DioException catch (e, st) {
      throw AppFailure(
        mapDioExceptionToMessage(e, defaultMessage: 'Impossible de charger les POIs.'),
        cause: e,
        stackTrace: st,
      );
    } catch (e, st) {
      throw AppFailure('Erreur inattendue lors du chargement des POIs.', cause: e, stackTrace: st);
    }

    final data = _asMap(response.data);
    if (data == null) return const <Poi>[];
    final elements = _asList(data['elements']);
    if (elements == null) return const <Poi>[];

    final pois = <Poi>[];
    for (final el in elements) {
      final em = _asMap(el);
      if (em == null) continue;
      final type = em['type']?.toString();
      final idRaw = em['id'];
      final latRaw = em['lat'];
      final lonRaw = em['lon'];
      if (type == null || idRaw == null || latRaw is! num || lonRaw is! num) continue;

      final tags = _asMap(em['tags']);
      if (tags == null) continue;

      final category = _categoryFromTags(tags);
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
