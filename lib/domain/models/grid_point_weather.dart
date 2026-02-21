import 'weather_condition.dart';

class GridPointWeather {
  final double latitude;
  final double longitude;
  final WeatherCondition condition;

  const GridPointWeather({
    required this.latitude,
    required this.longitude,
    required this.condition,
  });
}
