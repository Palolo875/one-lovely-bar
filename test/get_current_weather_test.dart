import 'package:flutter_test/flutter_test.dart';
import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/domain/models/route_models.dart';
import 'package:weathernav/domain/repositories/weather_repository.dart';
import 'package:weathernav/domain/usecases/get_current_weather.dart';

class _FakeWeatherRepository implements WeatherRepository {
  double? lastLat;
  double? lastLng;

  @override
  Future<WeatherCondition> getCurrentWeather(double lat, double lng) async {
    lastLat = lat;
    lastLng = lng;
    return WeatherCondition(
      temperature: 1,
      precipitation: 0,
      windSpeed: 2,
      windDirection: 0,
      weatherCode: 0,
      timestamp: DateTime(2026, 1),
    );
  }

  @override
  Future<List<WeatherCondition>> getBatchWeather(List<RoutePoint> points) {
    throw UnimplementedError();
  }

  @override
  Future<List<WeatherCondition>> getForecast(double lat, double lng, {int days = 7}) {
    throw UnimplementedError();
  }
}

void main() {
  test('GetCurrentWeather delegates to repository with same coordinates', () async {
    final repo = _FakeWeatherRepository();
    final usecase = GetCurrentWeather(repo);

    await usecase(12.34, 56.78);

    expect(repo.lastLat, 12.34);
    expect(repo.lastLng, 56.78);
  });
}
