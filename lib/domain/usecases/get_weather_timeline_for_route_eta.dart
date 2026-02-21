import '../models/route_models.dart';
import '../models/weather_condition.dart';
import '../repositories/weather_repository.dart';

class GetWeatherTimelineForRouteEta {
  final WeatherRepository _repository;

  const GetWeatherTimelineForRouteEta(this._repository);

  Future<List<WeatherCondition>> call({
    required RouteData route,
    required DateTime departureTime,
  }) async {
    if (route.points.isEmpty) return const <WeatherCondition>[];

    final sampled = _sample(route.points);
    final duration = Duration(
      seconds: (route.durationMinutes * 60).round().clamp(0, 365 * 24 * 3600),
    );

    final futures = <Future<WeatherCondition>>[];
    for (int i = 0; i < sampled.length; i++) {
      final fraction = sampled.length == 1 ? 0.0 : (i / (sampled.length - 1));
      final eta = departureTime.add(Duration(seconds: (duration.inSeconds * fraction).round()));
      futures.add(_getNearestHourly(sampled[i], eta));
    }

    return Future.wait(futures);
  }

  Future<WeatherCondition> _getNearestHourly(RoutePoint point, DateTime target) async {
    // Get enough hours around the target. Open-Meteo supports multiple days; we keep it simple.
    final forecast = await _repository.getForecast(point.latitude, point.longitude, days: 2);
    if (forecast.isEmpty) {
      // fallback to current weather if forecast is empty
      return _repository.getCurrentWeather(point.latitude, point.longitude);
    }

    WeatherCondition best = forecast.first;
    var bestDiff = (best.timestamp.difference(target)).abs();

    for (final c in forecast) {
      final diff = (c.timestamp.difference(target)).abs();
      if (diff < bestDiff) {
        best = c;
        bestDiff = diff;
      }
    }

    // Force the returned timestamp to be the ETA (for UI timeline)
    return best.copyWith(timestamp: target);
  }

  List<RoutePoint> _sample(List<RoutePoint> points) {
    if (points.length <= 5) return List<RoutePoint>.from(points);

    final sampled = <RoutePoint>[];
    for (int i = 0; i < 5; i++) {
      final index = (i * (points.length - 1) / 4).floor();
      sampled.add(points[index]);
    }
    return sampled;
  }
}
