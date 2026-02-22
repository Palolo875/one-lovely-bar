import 'package:weathernav/domain/models/weather_condition.dart';

class GridPointWeather {

  const GridPointWeather({
    required this.latitude,
    required this.longitude,
    required this.condition,
  });
  final double latitude;
  final double longitude;
  final WeatherCondition condition;
}
