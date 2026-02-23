import 'package:dio/dio.dart';
import 'package:weathernav/core/config/app_config.dart';
import 'package:weathernav/core/network/dio_error_mapper.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/models/route_models.dart';
import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/domain/repositories/weather_repository.dart';
import 'package:weathernav/domain/repositories/cache_repository.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';

class OpenMeteoRepository implements WeatherRepository {

  OpenMeteoRepository(this._dio, this._cache, {this.legacy});
  final Dio _dio;
  final CacheRepository _cache;
  final SettingsRepository? legacy;

  static const _currentTtl = Duration(minutes: 10);
  static const _forecastTtl = Duration(hours: 1);

  double _asDouble(dynamic v, {double fallback = 0.0}) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return fallback;
  }

  DateTime _asDateTime(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  List<dynamic>? _asList(dynamic v) {
    if (v is List) return v;
    return null;
  }

  String _keyForLatLng(String prefix, double lat, double lng) {
    // Reduce key explosion
    final latKey = lat.toStringAsFixed(3);
    final lngKey = lng.toStringAsFixed(3);
    return '$prefix:$latKey,$lngKey';
  }

  WeatherCondition? _readCurrentFromCache(double lat, double lng) {
    final key = _keyForLatLng('wx_current', lat, lng);
    final raw = _cache.get<Object?>(key) ?? legacy?.get<Object?>(key);
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
    final raw = _cache.get<Object?>(key) ?? legacy?.get<Object?>(key);
    if (raw is! Map) return null;
    final data = raw['data'];
    if (data is! Map) return null;
    return WeatherCondition.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> _writeCurrentToCache(double lat, double lng, WeatherCondition c) async {
    final key = _keyForLatLng('wx_current', lat, lng);
    await _cache.put(key, {
      'ts': DateTime.now().millisecondsSinceEpoch,
      'data': c.toJson(),
    });
  }

  List<WeatherCondition>? _readForecastFromCache(double lat, double lng, int days) {
    final key = _keyForLatLng('wx_forecast:$days', lat, lng);
    final raw = _cache.get<Object?>(key) ?? legacy?.get<Object?>(key);
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
    final raw = _cache.get<Object?>(key) ?? legacy?.get<Object?>(key);
    if (raw is! Map) return null;
    final data = raw['data'];
    if (data is! List) return null;
    return data
        .whereType<Map>()
        .map((m) => WeatherCondition.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> _writeForecastToCache(double lat, double lng, int days, List<WeatherCondition> list) async {
    final key = _keyForLatLng('wx_forecast:$days', lat, lng);
    await _cache.put(key, {
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
        '${AppConfig.openMeteoBaseUrl}/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'current_weather': true,
          'hourly': 'temperature_2m,precipitation,windspeed_10m,winddirection_10m,weathercode',
        },
      );
    } on DioException catch (e, st) {
      final stale = _readCurrentFromCacheAllowStale(lat, lng);
      if (stale != null) return stale;
      throw AppFailure(
        mapDioExceptionToMessage(e, defaultMessage: 'Impossible de récupérer la météo actuelle.'),
        cause: e,
        stackTrace: st,
      );
    } catch (e, st) {
      final stale = _readCurrentFromCacheAllowStale(lat, lng);
      if (stale != null) return stale;
      throw AppFailure('Erreur inattendue lors de la récupération de la météo actuelle.', cause: e, stackTrace: st);
    }

    final condition = () {
      try {
        final root = _asMap(response.data);
        final current = root == null ? null : _asMap(root['current_weather']);
        if (current == null) {
          throw const FormatException('Invalid Open-Meteo current_weather payload');
        }

        return WeatherCondition(
          temperature: _asDouble(current['temperature']),
          precipitation: 0,
          windSpeed: _asDouble(current['windspeed']),
          windDirection: _asDouble(current['winddirection']),
          weatherCode: _asInt(current['weathercode']),
          timestamp: _asDateTime(current['time']),
        );
      } catch (e, st) {
        throw AppFailure('Réponse météo invalide.', cause: e, stackTrace: st);
      }
    }();

    await _writeCurrentToCache(lat, lng, condition);
    return condition;
  }

  @override
  Future<List<WeatherCondition>> getForecast(double lat, double lng, {int days = 7}) async {
    final cached = _readForecastFromCache(lat, lng, days);
    if (cached != null) return cached;

    late final Response response;
    try {
      response = await _dio.get(
        '${AppConfig.openMeteoBaseUrl}/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'hourly': 'temperature_2m,precipitation,windspeed_10m,winddirection_10m,weathercode,visibility,uv_index,cloudcover',
          'forecast_days': days,
        },
      );
    } on DioException catch (e, st) {
      final stale = _readForecastFromCacheAllowStale(lat, lng, days);
      if (stale != null) return stale;
      throw AppFailure(
        mapDioExceptionToMessage(e, defaultMessage: 'Impossible de récupérer les prévisions météo.'),
        cause: e,
        stackTrace: st,
      );
    } catch (e, st) {
      final stale = _readForecastFromCacheAllowStale(lat, lng, days);
      if (stale != null) return stale;
      throw AppFailure('Erreur inattendue lors de la récupération des prévisions météo.', cause: e, stackTrace: st);
    }

    final conditions = () {
      try {
        final root = _asMap(response.data);
        final hourly = root == null ? null : _asMap(root['hourly']);
        if (hourly == null) {
          throw const FormatException('Invalid Open-Meteo hourly payload');
        }

        final times = _asList(hourly['time']);
        final temp = _asList(hourly['temperature_2m']);
        final precip = _asList(hourly['precipitation']);
        final wind = _asList(hourly['windspeed_10m']);
        final windDir = _asList(hourly['winddirection_10m']);
        final code = _asList(hourly['weathercode']);
        final vis = _asList(hourly['visibility']);
        final uv = _asList(hourly['uv_index']);
        final clouds = _asList(hourly['cloudcover']);

        final len = times?.length ?? 0;
        if (len == 0 ||
            temp == null ||
            precip == null ||
            wind == null ||
            windDir == null ||
            code == null ||
            vis == null ||
            uv == null ||
            clouds == null) {
          throw const FormatException('Invalid Open-Meteo hourly arrays');
        }

        final out = <WeatherCondition>[];
        for (var i = 0; i < len; i++) {
          out.add(
            WeatherCondition(
              temperature: _asDouble(temp[i]),
              precipitation: _asDouble(precip[i]),
              windSpeed: _asDouble(wind[i]),
              windDirection: _asDouble(windDir[i]),
              weatherCode: _asInt(code[i]),
              timestamp: _asDateTime(times[i]),
              visibility: _asDouble(vis[i]),
              uvIndex: _asDouble(uv[i]),
              cloudCover: _asDouble(clouds[i]),
            ),
          );
        }
        return out;
      } catch (e, st) {
        throw AppFailure('Réponse prévisions météo invalide.', cause: e, stackTrace: st);
      }
    }();

    await _writeForecastToCache(lat, lng, days, conditions);
    return conditions;
  }

  @override
  Future<List<WeatherCondition>> getBatchWeather(List<RoutePoint> points) async {
    if (points.isEmpty) return const <WeatherCondition>[];

    final safePoints = points.length <= 20 ? points : _evenSample(points, 20);

    // Open-Meteo supports batch requests by passing comma-separated lat/lng
    final lats = safePoints.map((p) => p.latitude).join(',');
    final lngs = safePoints.map((p) => p.longitude).join(',');

    // Note: For large routes, we might need to chunk this or use a different approach.
    // For now, let's assume it's a reasonable number of points.
    late final Response response;
    try {
      response = await _dio.get(
        '${AppConfig.openMeteoBaseUrl}/forecast',
        queryParameters: {
          'latitude': lats,
          'longitude': lngs,
          'hourly': 'temperature_2m,precipitation,windspeed_10m,weathercode',
          'forecast_days': 1,
        },
      );
    } on DioException catch (e, st) {
      throw AppFailure(
        mapDioExceptionToMessage(e, defaultMessage: 'Impossible de récupérer la météo sur le trajet.'),
        cause: e,
        stackTrace: st,
      );
    } catch (e, st) {
      throw AppFailure('Erreur inattendue lors de la récupération de la météo sur le trajet.', cause: e, stackTrace: st);
    }

    final dynamic raw = response.data;

    // Some Open-Meteo configurations return a list for multi-location, others return a single object.
    // If we can't reliably parse multi-location, we fall back to one request per point.
    if (raw is List) {
      final results = <WeatherCondition>[];
      for (final item in raw) {
        final itemMap = _asMap(item);
        if (itemMap == null) continue;
        final hourly = _asMap(itemMap['hourly']);
        if (hourly == null) continue;
        final times = _asList(hourly['time']);
        if (times == null || times.isEmpty) continue;

        results.add(WeatherCondition(
          temperature: _asDouble((_asList(hourly['temperature_2m']) ?? const [0])[0]),
          precipitation: _asDouble((_asList(hourly['precipitation']) ?? const [0])[0]),
          windSpeed: _asDouble((_asList(hourly['windspeed_10m']) ?? const [0])[0]),
          windDirection: 0,
          weatherCode: _asInt((_asList(hourly['weathercode']) ?? const [0])[0]),
          timestamp: _asDateTime(times[0]),
        ));
      }

      if (results.length == safePoints.length) {
        return results;
      }
    }

    if (raw is Map<String, dynamic>) {
      // If a single location was requested, parse normally.
      if (safePoints.length == 1 && raw['hourly'] is Map<String, dynamic>) {
        final hourly = raw['hourly'] as Map<String, dynamic>;
        final times = _asList(hourly['time']);
        if (times != null && times.isNotEmpty) {
          return [
            WeatherCondition(
              temperature: _asDouble((_asList(hourly['temperature_2m']) ?? const [0])[0]),
              precipitation: _asDouble((_asList(hourly['precipitation']) ?? const [0])[0]),
              windSpeed: _asDouble((_asList(hourly['windspeed_10m']) ?? const [0])[0]),
              windDirection: 0,
              weatherCode: _asInt((_asList(hourly['weathercode']) ?? const [0])[0]),
              timestamp: _asDateTime(times[0]),
            )
          ];
        }
      }
    }

    // Fallback: one request per point.
    try {
      return await Future.wait(
        safePoints.map((p) => getCurrentWeather(p.latitude, p.longitude)),
      );
    } on AppFailure {
      rethrow;
    } catch (e, st) {
      throw AppFailure('Impossible de récupérer la météo sur le trajet.', cause: e, stackTrace: st);
    }
  }

  List<RoutePoint> _evenSample(List<RoutePoint> points, int max) {
    if (points.length <= max) return List<RoutePoint>.from(points);
    if (max <= 0) return const <RoutePoint>[];
    if (max == 1) return [points.first];

    final out = <RoutePoint>[];
    for (var i = 0; i < max; i++) {
      final index = (i * (points.length - 1) / (max - 1)).round();
      out.add(points[index.clamp(0, points.length - 1)]);
    }
    return out;
  }
}
