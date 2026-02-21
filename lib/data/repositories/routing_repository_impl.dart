import 'dart:convert';
import 'package:dio/dio.dart';
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
    final response = await _dio.get(
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

    // Simplification for the mock/initial impl. Valhalla response is complex.
    // In a real app, we'd parse the 'trip' and 'shape' (encoded polyline).

    return RouteData(
      points: [
        RoutePoint(latitude: startLat, longitude: startLng),
        RoutePoint(latitude: endLat, longitude: endLng),
      ],
      distanceKm: 0.0,
      durationMinutes: 0.0,
      profile: profile,
    );
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
