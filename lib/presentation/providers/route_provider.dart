import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/route_models.dart';
import '../../domain/usecases/get_route.dart';
import 'repository_providers.dart';

class RouteRequest {
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final String profile;

  const RouteRequest({
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.profile,
  });

  @override
  bool operator ==(Object other) {
    return other is RouteRequest &&
        other.startLat == startLat &&
        other.startLng == startLng &&
        other.endLat == endLat &&
        other.endLng == endLng &&
        other.profile == profile;
  }

  @override
  int get hashCode => Object.hash(startLat, startLng, endLat, endLng, profile);
}

final routeProvider = FutureProvider.autoDispose.family<RouteData, RouteRequest>((ref, request) async {
  final repo = ref.watch(routingRepositoryProvider);
  return GetRoute(repo)(
    startLat: request.startLat,
    startLng: request.startLng,
    endLat: request.endLat,
    endLng: request.endLng,
    profile: request.profile,
  );
});
