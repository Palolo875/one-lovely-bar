import 'package:weathernav/domain/models/grid_point_weather.dart';
import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/domain/repositories/weather_repository.dart';

class GetWeatherGrid {

  const GetWeatherGrid(this._repository);
  final WeatherRepository _repository;

  Future<List<GridPointWeather>> call({
    required double centerLat,
    required double centerLng,
    required int gridSize,
    required double stepDegrees,
  }) async {
    final points = <(double, double)>[];
    final half = gridSize ~/ 2;

    for (var y = -half; y <= half; y++) {
      for (var x = -half; x <= half; x++) {
        points.add((centerLat + y * stepDegrees, centerLng + x * stepDegrees));
      }
    }

    final results = <GridPointWeather>[];
    const batchSize = 3;

    for (var i = 0; i < points.length; i += batchSize) {
      final batch = points.skip(i).take(batchSize);
      final futures = batch.map((p) async {
        final forecast = await _repository.getForecast(p.$1, p.$2, days: 1);
        WeatherCondition base;
        if (forecast.isEmpty) {
          base = await _repository.getCurrentWeather(p.$1, p.$2);
        } else {
          final target = DateTime.now();
          base = _closest(forecast, target);
        }

        return GridPointWeather(latitude: p.$1, longitude: p.$2, condition: base);
      });
      results.addAll(await Future.wait(futures));
    }

    return results;
  }

  WeatherCondition _closest(List<WeatherCondition> list, DateTime target) {
    var best = list.first;
    var bestDiff = best.timestamp.difference(target).abs();
    for (final c in list) {
      final d = c.timestamp.difference(target).abs();
      if (d < bestDiff) {
        best = c;
        bestDiff = d;
      }
    }
    return best;
  }
}
