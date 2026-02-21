import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/rainviewer_repository.dart';

class RainViewerRepositoryImpl implements RainViewerRepository {
  final Dio _dio;
  final Box _settings;

  RainViewerRepositoryImpl(this._dio) : _settings = Hive.box('settings');

  static const _ttl = Duration(minutes: 5);
  static const _key = 'rainviewer_latest_time';

  @override
  Future<int?> getLatestRadarTime() async {
    final cached = _readCache(freshOnly: true);
    if (cached != null) return cached;

    late final Response response;
    try {
      response = await _dio.get('https://api.rainviewer.com/public/weather-maps.json');
    } on DioException catch (e) {
      final stale = _readCache(freshOnly: false);
      if (stale != null) return stale;
      throw AppFailure('Impossible de récupérer le radar pluie.', cause: e);
    } catch (e) {
      final stale = _readCache(freshOnly: false);
      if (stale != null) return stale;
      throw AppFailure('Erreur inattendue lors de la récupération du radar pluie.', cause: e);
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) return null;
    final radar = data['radar'];
    if (radar is! Map<String, dynamic>) return null;
    final past = radar['past'];
    if (past is! List || past.isEmpty) return null;

    final last = past.last;
    if (last is! Map<String, dynamic>) return null;
    final time = last['time'];
    if (time is! num) return null;

    final v = time.toInt();
    _settings.put(_key, {
      'ts': DateTime.now().millisecondsSinceEpoch,
      'time': v,
    });
    return v;
  }

  int? _readCache({required bool freshOnly}) {
    final raw = _settings.get(_key);
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
