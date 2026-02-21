import 'package:dio/dio.dart';
import '../../domain/models/weather_condition.dart';
import '../../domain/repositories/weather_repository.dart';

class OpenMeteoRepository implements WeatherRepository {
  final Dio _dio;

  OpenMeteoRepository(this._dio);

  @override
  Future<WeatherCondition> getCurrentWeather(double lat, double lng) async {
    final response = await _dio.get(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {
        'latitude': lat,
        'longitude': lng,
        'current_weather': true,
        'hourly': 'temperature_2m,precipitation,windspeed_10m,winddirection_10m,weathercode',
      },
    );

    final current = response.data['current_weather'];
    return WeatherCondition(
      temperature: current['temperature'],
      precipitation: 0.0, // Open-Meteo current doesn't always have it directly
      windSpeed: current['windspeed'],
      windDirection: current['winddirection'],
      weatherCode: current['weathercode'],
      timestamp: DateTime.parse(current['time']),
    );
  }

  @override
  Future<List<WeatherCondition>> getForecast(double lat, double lng, {int days = 7}) async {
    final response = await _dio.get(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {
        'latitude': lat,
        'longitude': lng,
        'hourly': 'temperature_2m,precipitation,windspeed_10m,winddirection_10m,weathercode,visibility,uv_index,cloudcover',
        'forecast_days': days,
      },
    );

    final hourly = response.data['hourly'];
    final List<WeatherCondition> conditions = [];
    for (int i = 0; i < (hourly['time'] as List).length; i++) {
      conditions.add(WeatherCondition(
        temperature: hourly['temperature_2m'][i],
        precipitation: hourly['precipitation'][i],
        windSpeed: hourly['windspeed_10m'][i],
        windDirection: hourly['winddirection_10m'][i],
        weatherCode: hourly['weathercode'][i],
        timestamp: DateTime.parse(hourly['time'][i]),
        visibility: hourly['visibility'][i].toDouble(),
        uvIndex: hourly['uv_index'][i].toDouble(),
        cloudCover: hourly['cloudcover'][i].toDouble(),
      ));
    }
    return conditions;
  }

  @override
  Future<List<WeatherCondition>> getBatchWeather(List<Map<String, dynamic>> points) async {
    // Open-Meteo supports batch requests by passing comma-separated lat/lng
    final lats = points.map((p) => p['lat']).join(',');
    final lngs = points.map((p) => p['lng']).join(',');

    // Note: For large routes, we might need to chunk this or use a different approach.
    // For now, let's assume it's a reasonable number of points.
    final response = await _dio.get(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {
        'latitude': lats,
        'longitude': lngs,
        'hourly': 'temperature_2m,precipitation,windspeed_10m,weathercode',
        'forecast_days': 1,
      },
    );

    // Response for multiple locations is a list of objects if multiple lats are provided
    final List<dynamic> data = response.data is List ? response.data : [response.data];

    final List<WeatherCondition> results = [];
    for (var locationData in data) {
      final hourly = locationData['hourly'];
      // We take the first hour for simplicity or the one closest to requested time if provided
      results.add(WeatherCondition(
        temperature: hourly['temperature_2m'][0],
        precipitation: hourly['precipitation'][0],
        windSpeed: hourly['windspeed_10m'][0],
        windDirection: 0.0,
        weatherCode: hourly['weathercode'][0],
        timestamp: DateTime.parse(hourly['time'][0]),
      ));
    }
    return results;
  }
}
