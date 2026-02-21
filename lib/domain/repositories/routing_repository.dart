import '../models/route_models.dart';

abstract class RoutingRepository {
  Future<RouteData> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String profile,
  });
}
