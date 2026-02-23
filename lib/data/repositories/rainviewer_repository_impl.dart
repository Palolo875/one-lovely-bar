import 'package:dio/dio.dart';
import 'package:weathernav/core/config/app_config.dart';
import 'package:weathernav/core/network/dio_error_mapper.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/repositories/cache_repository.dart';
import 'package:weathernav/domain/repositories/rainviewer_repository.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';

class RainViewerRepositoryImpl implements RainViewerRepository {

  RainViewerRepositoryImpl(this._dio, this._cache, {this.legacy});
  final Dio _dio;
  final CacheRepository _cache;
  final SettingsRepository? legacy;

  static const _ttl = Duration(minutes: 5);
  static const _key = 'rainviewer_latest_time';

  Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  List<dynamic>? _asList(dynamic v) {
    if (v is List) return v;
    return null;
  }

  @override
  Future<int?> getLatestRadarTime() async {
    final cached = _readCache(freshOnly: true);
    if (cached != null) return cached;

    late final Response response;
    try {
      response = await _dio.get('${AppConfig.rainviewerApiBaseUrl}/public/weather-maps.json');
    } on DioException catch (e, st) {
      final stale = _readCache(freshOnly: false);
      if (stale != null) return stale;
      throw AppFailure(
        mapDioExceptionToMessage(e, defaultMessage: 'Impossible de récupérer le radar pluie.'),
        cause: e,
        stackTrace: st,
      );
    } catch (e, st) {
      final stale = _readCache(freshOnly: false);
      if (stale != null) return stale;
      throw AppFailure('Erreur inattendue lors de la récupération du radar pluie.', cause: e, stackTrace: st);
    }

    final data = _asMap(response.data);
    if (data == null) return null;
    final radar = _asMap(data['radar']);
    if (radar == null) return null;
    final past = _asList(radar['past']);
    if (past == null || past.isEmpty) return null;

    final last = _asMap(past.last);
    if (last == null) return null;
    final time = last['time'];
    if (time is! num) return null;

    final v = time.toInt();
    await _cache.put(_key, {
      'ts': DateTime.now().millisecondsSinceEpoch,
      'time': v,
    });
    return v;
  }

  int? _readCache({required bool freshOnly}) {
    final raw = _cache.get<Object?>(_key) ?? legacy?.get<Object?>(_key);
    if (raw is! Map) return null;
    final ts = raw['ts'];
    final time = raw['time'];
    if (ts is! int || time is! int) return null;
    if (!freshOnly) return time;

    final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
    if (age > _ttl) return null;
    return time;
  }
}
