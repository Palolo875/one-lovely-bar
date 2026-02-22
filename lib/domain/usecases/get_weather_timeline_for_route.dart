import 'package:weathernav/domain/models/route_models.dart';
import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/domain/repositories/weather_repository.dart';

class GetWeatherTimelineForRoute {

  const GetWeatherTimelineForRoute(this._repository);
  final WeatherRepository _repository;

  Future<List<WeatherCondition>> call(RouteData route) {
    if (route.points.isEmpty) return Future.value(const <WeatherCondition>[]);
    return _repository.getBatchWeather(_sample(route.points));
  }

  List<RoutePoint> _sample(List<RoutePoint> points) {
    if (points.length <= 5) return List<RoutePoint>.from(points);

    final sampled = <RoutePoint>[];
    for (var i = 0; i < 5; i++) {
      final index = (i * (points.length - 1) / 4).floor();
      sampled.add(points[index]);
    }
    return sampled;
  }
}
