import 'package:weathernav/domain/models/route_models.dart';
import 'package:weathernav/domain/repositories/routing_repository.dart';

class GetRoute {

  const GetRoute(this._repository);
  final RoutingRepository _repository;

  Future<RouteData> call({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String profile,
    List<RoutePoint>? waypoints,
  }) {
    return _repository.getRoute(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      profile: profile,
      waypoints: waypoints,
    );
  }
}
