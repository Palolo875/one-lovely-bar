import 'package:weathernav/domain/models/route_instruction.dart';
import 'package:weathernav/domain/models/route_models.dart';
import 'package:weathernav/domain/repositories/routing_repository.dart';

class GetRouteInstructions {

  const GetRouteInstructions(this._repository);
  final RoutingRepository _repository;

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
