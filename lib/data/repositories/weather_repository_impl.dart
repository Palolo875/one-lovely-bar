import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/models/route_models.dart';
import '../../domain/models/weather_condition.dart';
import '../../domain/repositories/weather_repository.dart';

class OpenMeteoRepository implements WeatherRepository {
  final Dio _dio;
  final Box _settings;

  OpenMeteoRepository(this._dio) : _settings = Hive.box('settings');

  static const _currentTtl = Duration(minutes: 10);
  static const _forecastTtl = Duration(hours: 1);

  String _keyForLatLng(String prefix, double lat, double lng) {
    // Reduce key explosion
    final latKey = lat.toStringAsFixed(3);
    final lngKey = lng.toStringAsFixed(3);
    return '$prefix:$latKey,$lngKey';
  }

  WeatherCondition? _readCurrentFromCache(double lat, double lng) {
    final key = _keyForLatLng('wx_current', lat, lng);
    final raw = _settings.get(key);
    if (raw is! Map) return null;
    final ts = raw['ts'];
    final data = raw['data'];
    if (ts is! int || data is! Map) return null;
    final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
    if (age > _currentTtl) return null;
    return WeatherCondition.fromJson(Map<String, dynamic>.from(data));
  }

  WeatherCondition? _readCurrentFromCacheAllowStale(double lat, double lng) {
    final key = _keyForLatLng('wx_current', lat, lng);
    final raw = _settings.get(key);
    if (raw is! Map) return null;
    final data = raw['data'];
    if (data is! Map) return null;
    return WeatherCondition.fromJson(Map<String, dynamic>.from(data));
  }

  void _writeCurrentToCache(double lat, double lng, WeatherCondition c) {
    final key = _keyForLatLng('wx_current', lat, lng);
    _settings.put(key, {
      'ts': DateTime.now().millisecondsSinceEpoch,
      'data': c.toJson(),
    });
  }

  List<WeatherCondition>? _readForecastFromCache(double lat, double lng, int days) {
    final key = _keyForLatLng('wx_forecast:$days', lat, lng);
    final raw = _settings.get(key);
    if (raw is! Map) return null;
    final ts = raw['ts'];
    final data = raw['data'];
    if (ts is! int || data is! List) return null;
    final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
    if (age > _forecastTtl) return null;
    return data
        .whereType<Map>()
        .map((m) => WeatherCondition.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  List<WeatherCondition>? _readForecastFromCacheAllowStale(double lat, double lng, int days) {
    final key = _keyForLatLng('wx_forecast:$days', lat, lng);
    final raw = _settings.get(key);
    if (raw is! Map) return null;
    final data = raw['data'];
    if (data is! List) return null;
    return data
        .whereType<Map>()
        .map((m) => WeatherCondition.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  void _writeForecastToCache(double lat, double lng, int days, List<WeatherCondition> list) {
    final key = _keyForLatLng('wx_forecast:$days', lat, lng);
    _settings.put(key, {
      'ts': DateTime.now().millisecondsSinceEpoch,
      'data': list.map((c) => c.toJson()).toList(),
    });
  }

  @override
  Future<WeatherCondition> getCurrentWeather(double lat, double lng) async {
    final cached = _readCurrentFromCache(lat, lng);
    if (cached != null) return cached;

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
      final stale = _readCurrentFromCacheAllowStale(lat, lng);
      if (stale != null) return stale;
      throw AppFailure('Impossible de récupérer la météo actuelle.', cause: e);
    } catch (e) {
      final stale = _readCurrentFromCacheAllowStale(lat, lng);
      if (stale != null) return stale;
      throw AppFailure('Erreur inattendue lors de la récupération de la météo actuelle.', cause: e);
    }

    final current = response.data['current_weather'];
    final condition = WeatherCondition(
      temperature: current['temperature'],
      precipitation: 0.0, // Open-Meteo current doesn't always have it directly
      windSpeed: current['windspeed'],
      windDirection: current['winddirection'],
      weatherCode: current['weathercode'],
      timestamp: DateTime.parse(current['time']),
    );

    _writeCurrentToCache(lat, lng, condition);
    return condition;
  }

  @override
  Future<List<WeatherCondition>> getForecast(double lat, double lng, {int days = 7}) async {
    final cached = _readForecastFromCache(lat, lng, days);
    if (cached != null) return cached;

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
      final stale = _readForecastFromCacheAllowStale(lat, lng, days);
      if (stale != null) return stale;
      throw AppFailure('Impossible de récupérer les prévisions météo.', cause: e);
    } catch (e) {
      final stale = _readForecastFromCacheAllowStale(lat, lng, days);
      if (stale != null) return stale;
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

    _writeForecastToCache(lat, lng, days, conditions);
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
