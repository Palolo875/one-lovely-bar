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
  final DateTime? departureTime;
  final List<RoutePoint>? waypoints;

  const RouteRequest({
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.profile,
    this.departureTime,
    this.waypoints,
  });

  @override
  bool operator ==(Object other) {
    return other is RouteRequest &&
        other.startLat == startLat &&
        other.startLng == startLng &&
        other.endLat == endLat &&
        other.endLng == endLng &&
        other.profile == profile &&
        other.departureTime == departureTime &&
        _listEquals(other.waypoints, waypoints);
  }

  @override
  int get hashCode => Object.hash(startLat, startLng, endLat, endLng, profile, departureTime, _listHash(waypoints));
}

bool _listEquals(List<RoutePoint>? a, List<RoutePoint>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

int _listHash(List<RoutePoint>? a) {
  if (a == null) return 0;
  int h = 0;
  for (final p in a) {
    h = 0x1fffffff & (h + p.hashCode);
  }
  return h;
}

final routeProvider = FutureProvider.autoDispose.family<RouteData, RouteRequest>((ref, request) async {
  final repo = ref.watch(routingRepositoryProvider);
  return GetRoute(repo)(
    startLat: request.startLat,
    startLng: request.startLng,
    endLat: request.endLat,
    endLng: request.endLng,
    profile: request.profile,
    waypoints: request.waypoints,
  );
});
