import '../models/route_instruction.dart';
import '../models/route_models.dart';
import '../repositories/routing_repository.dart';

class GetRouteInstructions {
  final RoutingRepository _repository;

  const GetRouteInstructions(this._repository);

  Future<List<RouteInstruction>> call({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String profile,
    List<RoutePoint>? waypoints,
  }) {
    return _repository.getRouteInstructions(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      profile: profile,
      waypoints: waypoints,
    );
  }
}
