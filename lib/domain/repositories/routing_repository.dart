import '../models/route_models.dart';
import '../models/route_instruction.dart';

abstract class RoutingRepository {
  Future<RouteData> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String profile,
    List<RoutePoint>? waypoints,
  });

  Future<List<RouteInstruction>> getRouteInstructions({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String profile,
    List<RoutePoint>? waypoints,
  });
}
