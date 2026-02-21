import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/models/route_models.dart';
import '../../domain/repositories/routing_repository.dart';

class ValhallaRoutingRepository implements RoutingRepository {
  final Dio _dio;

  ValhallaRoutingRepository(this._dio);

  @override
  Future<RouteData> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String profile,
  }) async {
    late final Response response;
    try {
      response = await _dio.get(
        'https://valhalla.openstreetmap.de/route',
        queryParameters: {
          'json': jsonEncode({
            'locations': [
              {'lat': startLat, 'lon': startLng},
              {'lat': endLat, 'lon': endLng}
            ],
            'costing': _mapProfileToCosting(profile),
            'units': 'kilometers'
          })
        },
      );
    } on DioException catch (e) {
      throw AppFailure('Impossible de calculer l’itinéraire.', cause: e);
    } catch (e) {
      throw AppFailure('Erreur inattendue lors du calcul de l’itinéraire.', cause: e);
    }

    final data = response.data as Map<String, dynamic>;
    final trip = (data['trip'] ?? const <String, dynamic>{}) as Map<String, dynamic>;
    final summary = (trip['summary'] ?? const <String, dynamic>{}) as Map<String, dynamic>;

    final distanceKm = (summary['length'] is num)
        ? (summary['length'] as num).toDouble()
        : 0.0;
    final durationSeconds = (summary['time'] is num)
        ? (summary['time'] as num).toDouble()
        : 0.0;

    final legs = (trip['legs'] is List) ? (trip['legs'] as List) : const [];
    final leg0 = legs.isNotEmpty && legs.first is Map<String, dynamic>
        ? legs.first as Map<String, dynamic>
        : const <String, dynamic>{};
    final shape = leg0['shape'] as String?;

    final decoded = shape == null
        ? <RoutePoint>[
            RoutePoint(latitude: startLat, longitude: startLng),
            RoutePoint(latitude: endLat, longitude: endLng),
          ]
        : _decodeValhallaPolyline(shape);

    final points = decoded.isEmpty
        ? <RoutePoint>[
            RoutePoint(latitude: startLat, longitude: startLng),
            RoutePoint(latitude: endLat, longitude: endLng),
          ]
        : decoded;

    return RouteData(
      points: points,
      distanceKm: distanceKm,
      durationMinutes: durationSeconds / 60.0,
      profile: profile,
    );
  }

  List<RoutePoint> _decodeValhallaPolyline(String encoded) {
    final points6 = _decodePolyline(encoded, precision: 6);
    if (points6.isNotEmpty) {
      final p0 = points6.first;
      if (p0.latitude.abs() <= 90 && p0.longitude.abs() <= 180) {
        return points6;
      }
    }
    final points5 = _decodePolyline(encoded, precision: 5);
    return points5;
  }

  List<RoutePoint> _decodePolyline(String encoded, {required int precision}) {
    final factor = 1 / (pow10(precision));
    int index = 0;
    int lat = 0;
    int lng = 0;
    final coordinates = <RoutePoint>[];

    try {
      while (index < encoded.length) {
        final latResult = _decodePolylineValue(encoded, index);
        index = latResult.nextIndex;
        lat += latResult.delta;

        if (index >= encoded.length) break;

        final lngResult = _decodePolylineValue(encoded, index);
        index = lngResult.nextIndex;
        lng += lngResult.delta;

        coordinates.add(RoutePoint(
          latitude: lat * factor,
          longitude: lng * factor,
        ));
      }
    } catch (_) {
      return const <RoutePoint>[];
    }

    return coordinates;
  }

  _PolylineDelta _decodePolylineValue(String encoded, int startIndex) {
    int index = startIndex;
    int result = 0;
    int shift = 0;
    int b;
    do {
      if (index >= encoded.length) {
        throw const FormatException('Invalid polyline');
      }
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20 && index < encoded.length);

    final delta = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
    return _PolylineDelta(delta: delta, nextIndex: index);
  }

  double pow10(int precision) {
    double v = 1;
    for (var i = 0; i < precision; i++) {
      v *= 10;
    }
    return v;
  }

  String _mapProfileToCosting(String profile) {
    switch (profile) {
      case 'cyclist': return 'bicycle';
      case 'hiker': return 'pedestrian';
      case 'driver': return 'auto';
      default: return 'auto';
    }
  }
}

class _PolylineDelta {
  final int delta;
  final int nextIndex;

  const _PolylineDelta({required this.delta, required this.nextIndex});
}
