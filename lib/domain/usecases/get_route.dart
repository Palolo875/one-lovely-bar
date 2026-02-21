import '../models/route_models.dart';
import '../repositories/routing_repository.dart';

class GetRoute {
  final RoutingRepository _repository;

  const GetRoute(this._repository);

  Future<RouteData> call({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String profile,
  }) {
    return _repository.getRoute(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      profile: profile,
    );
  }
}
