import 'package:flutter_test/flutter_test.dart';
import 'package:weathernav/domain/models/route_models.dart';
import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/domain/repositories/weather_repository.dart';
import 'package:weathernav/domain/usecases/get_weather_timeline_for_route.dart';

class _FakeWeatherRepository implements WeatherRepository {
  List<RoutePoint>? lastBatch;
  int batchCallCount = 0;

  @override
  Future<List<WeatherCondition>> getBatchWeather(List<RoutePoint> points) async {
    batchCallCount += 1;
    lastBatch = points;
    return points
        .map(
          (p) => WeatherCondition(
            temperature: 20,
            precipitation: 0,
            windSpeed: 5,
            windDirection: 0,
            weatherCode: 0,
            timestamp: DateTime(2026),
          ),
        )
        .toList();
  }

  @override
  Future<WeatherCondition> getCurrentWeather(double lat, double lng) {
    throw UnimplementedError();
  }

  @override
  Future<List<WeatherCondition>> getForecast(double lat, double lng, {int days = 7}) {
    throw UnimplementedError();
  }
}

void main() {
  test('GetWeatherTimelineForRoute samples 5 points for long routes', () async {
    final repo = _FakeWeatherRepository();
    final usecase = GetWeatherTimelineForRoute(repo);

    final route = RouteData(
      points: List.generate(
        101,
        (i) => RoutePoint(latitude: i.toDouble(), longitude: i.toDouble()),
      ),
      distanceKm: 10,
      durationMinutes: 30,
      profile: 'driver',
    );

    await usecase(route);

    expect(repo.lastBatch, isNotNull);
    expect(repo.lastBatch!.length, 5);

    final idx = repo.lastBatch!.map((p) => p.latitude.toInt()).toList();
    expect(idx, [0, 25, 50, 75, 100]);
  });

  test('GetWeatherTimelineForRoute keeps all points when route is short', () async {
    final repo = _FakeWeatherRepository();
    final usecase = GetWeatherTimelineForRoute(repo);

    final route = RouteData(
      points: List.generate(
        3,
        (i) => RoutePoint(latitude: i.toDouble(), longitude: i.toDouble()),
      ),
      distanceKm: 1,
      durationMinutes: 5,
      profile: 'driver',
    );

    await usecase(route);

    expect(repo.lastBatch, isNotNull);
    expect(repo.lastBatch!.length, 3);
  });

  test('GetWeatherTimelineForRoute returns empty list for empty routes', () async {
    final repo = _FakeWeatherRepository();
    final usecase = GetWeatherTimelineForRoute(repo);

    const route = RouteData(
      points: [],
      distanceKm: 0,
      durationMinutes: 0,
      profile: 'driver',
    );

    final result = await usecase(route);

    expect(result, isEmpty);
    expect(repo.batchCallCount, 0);
    expect(repo.lastBatch, isNull);
  });
}
