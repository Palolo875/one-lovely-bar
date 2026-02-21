import '../models/weather_condition.dart';
import '../models/route_models.dart';

abstract class WeatherRepository {
  Future<WeatherCondition> getCurrentWeather(double lat, double lng);
  Future<List<WeatherCondition>> getForecast(double lat, double lng, {int days = 7});
  Future<List<WeatherCondition>> getBatchWeather(List<RoutePoint> points);
}
