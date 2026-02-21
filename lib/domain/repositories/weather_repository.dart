import '../models/weather_condition.dart';

abstract class WeatherRepository {
  Future<WeatherCondition> getCurrentWeather(double lat, double lng);
  Future<List<WeatherCondition>> getForecast(double lat, double lng, {int days = 7});
  Future<List<WeatherCondition>> getBatchWeather(List<Map<String, dynamic>> points);
}
