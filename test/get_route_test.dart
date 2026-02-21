import 'package:flutter_test/flutter_test.dart';
import 'package:weathernav/domain/models/route_models.dart';
import 'package:weathernav/domain/repositories/routing_repository.dart';
import 'package:weathernav/domain/usecases/get_route.dart';

class _FakeRoutingRepository implements RoutingRepository {
  Map<String, Object?>? lastArgs;

  @override
  Future<RouteData> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String profile,
    List<RoutePoint>? waypoints,
  }) async {
    lastArgs = {
      'startLat': startLat,
      'startLng': startLng,
      'endLat': endLat,
      'endLng': endLng,
      'profile': profile,
      'waypoints': waypoints,
    };

    return RouteData(
      points: [
        RoutePoint(latitude: startLat, longitude: startLng),
        RoutePoint(latitude: endLat, longitude: endLng),
      ],
      distanceKm: 1,
      durationMinutes: 2,
      profile: profile,
    );
  }
}

void main() {
  test('GetRoute delegates to repository with same arguments', () async {
    final repo = _FakeRoutingRepository();
    final usecase = GetRoute(repo);

    await usecase(
      startLat: 1.1,
      startLng: 2.2,
      endLat: 3.3,
      endLng: 4.4,
      profile: 'driver',
    );

    expect(repo.lastArgs, isNotNull);
    expect(repo.lastArgs!['startLat'], 1.1);
    expect(repo.lastArgs!['startLng'], 2.2);
    expect(repo.lastArgs!['endLat'], 3.3);
    expect(repo.lastArgs!['endLng'], 4.4);
    expect(repo.lastArgs!['profile'], 'driver');
    expect(repo.lastArgs!['waypoints'], isNull);
  });
}
