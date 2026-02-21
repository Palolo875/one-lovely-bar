import 'package:dio/dio.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/models/route_models.dart';
import '../../domain/models/weather_condition.dart';
import '../../domain/repositories/weather_repository.dart';

class OpenMeteoRepository implements WeatherRepository {
  final Dio _dio;

  OpenMeteoRepository(this._dio);

  @override
  Future<WeatherCondition> getCurrentWeather(double lat, double lng) async {
    late final Response response;
    try {
      response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'current_weather': true,
          'hourly': 'temperature_2m,precipitation,windspeed_10m,winddirection_10m,weathercode',
        },
      );
    } on DioException catch (e) {
      throw AppFailure('Impossible de récupérer la météo actuelle.', cause: e);
    } catch (e) {
      throw AppFailure('Erreur inattendue lors de la récupération de la météo actuelle.', cause: e);
    }

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
    late final Response response;
    try {
      response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'hourly': 'temperature_2m,precipitation,windspeed_10m,winddirection_10m,weathercode,visibility,uv_index,cloudcover',
          'forecast_days': days,
        },
      );
    } on DioException catch (e) {
      throw AppFailure('Impossible de récupérer les prévisions météo.', cause: e);
    } catch (e) {
      throw AppFailure('Erreur inattendue lors de la récupération des prévisions météo.', cause: e);
    }

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
  Future<List<WeatherCondition>> getBatchWeather(List<RoutePoint> points) async {
    if (points.isEmpty) return const <WeatherCondition>[];

    // Open-Meteo supports batch requests by passing comma-separated lat/lng
    final lats = points.map((p) => p.latitude).join(',');
    final lngs = points.map((p) => p.longitude).join(',');

    // Note: For large routes, we might need to chunk this or use a different approach.
    // For now, let's assume it's a reasonable number of points.
    late final Response response;
    try {
      response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lats,
          'longitude': lngs,
          'hourly': 'temperature_2m,precipitation,windspeed_10m,weathercode',
          'forecast_days': 1,
        },
      );
    } on DioException catch (e) {
      throw AppFailure('Impossible de récupérer la météo sur le trajet.', cause: e);
    } catch (e) {
      throw AppFailure('Erreur inattendue lors de la récupération de la météo sur le trajet.', cause: e);
    }

    final dynamic raw = response.data;

    // Some Open-Meteo configurations return a list for multi-location, others return a single object.
    // If we can't reliably parse multi-location, we fall back to one request per point.
    if (raw is List) {
      final results = <WeatherCondition>[];
      for (final item in raw) {
        if (item is! Map<String, dynamic>) continue;
        final hourly = item['hourly'];
        if (hourly is! Map<String, dynamic>) continue;
        final times = hourly['time'];
        if (times is! List || times.isEmpty) continue;

        results.add(WeatherCondition(
          temperature: (hourly['temperature_2m'][0] as num).toDouble(),
          precipitation: (hourly['precipitation'][0] as num).toDouble(),
          windSpeed: (hourly['windspeed_10m'][0] as num).toDouble(),
          windDirection: 0.0,
          weatherCode: (hourly['weathercode'][0] as num).toInt(),
          timestamp: DateTime.parse(times[0] as String),
        ));
      }

      if (results.length == points.length) {
        return results;
      }
    }

    if (raw is Map<String, dynamic>) {
      // If a single location was requested, parse normally.
      if (points.length == 1 && raw['hourly'] is Map<String, dynamic>) {
        final hourly = raw['hourly'] as Map<String, dynamic>;
        final times = hourly['time'];
        if (times is List && times.isNotEmpty) {
          return [
            WeatherCondition(
              temperature: (hourly['temperature_2m'][0] as num).toDouble(),
              precipitation: (hourly['precipitation'][0] as num).toDouble(),
              windSpeed: (hourly['windspeed_10m'][0] as num).toDouble(),
              windDirection: 0.0,
              weatherCode: (hourly['weathercode'][0] as num).toInt(),
              timestamp: DateTime.parse(times[0] as String),
            )
          ];
        }
      }
    }

    // Fallback: one request per point.
    try {
      return await Future.wait(
        points.map((p) => getCurrentWeather(p.latitude, p.longitude)),
      );
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw AppFailure('Impossible de récupérer la météo sur le trajet.', cause: e);
    }
  }
}
