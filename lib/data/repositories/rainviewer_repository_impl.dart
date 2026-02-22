import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/repositories/rainviewer_repository.dart';

class RainViewerRepositoryImpl implements RainViewerRepository {

  RainViewerRepositoryImpl(this._dio) : _settings = Hive.box('settings');
  final Dio _dio;
  final Box _settings;

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
