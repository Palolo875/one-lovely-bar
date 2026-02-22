import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernav/domain/models/grid_point_weather.dart';
import 'package:weathernav/domain/usecases/get_weather_grid.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/presentation/providers/repository_providers.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';

class WeatherGridRequest {

  const WeatherGridRequest({
    required this.centerLat,
    required this.centerLng,
    this.gridSize = 3,
    this.stepDegrees = 0.03,
  });
  final double centerLat;
  final double centerLng;
  final int gridSize;
  final double stepDegrees;

  @override
  bool operator ==(Object other) {
    return other is WeatherGridRequest &&
        other.centerLat == centerLat &&
        other.centerLng == centerLng &&
        other.gridSize == gridSize &&
        other.stepDegrees == stepDegrees;
  }

  @override
  int get hashCode => Object.hash(centerLat, centerLng, gridSize, stepDegrees);
}

final weatherGridProvider = FutureProvider.autoDispose.family<List<GridPointWeather>, WeatherGridRequest>((ref, req) async {
  final repo = ref.watch(weatherRepositoryProvider);

  final settings = ref.watch(settingsRepositoryProvider);

  const ttl = Duration(minutes: 5);
  final key = 'wx_grid:${req.centerLat.toStringAsFixed(3)},${req.centerLng.toStringAsFixed(3)}:${req.gridSize}:${req.stepDegrees.toStringAsFixed(3)}';

  List<GridPointWeather>? readCache({required bool freshOnly}) {
    final raw = settings.get<Object?>(key);
    if (raw is! Map) return null;
    final ts = raw['ts'];
    final data = raw['data'];
    if (ts is! int || data is! List) return null;
    if (freshOnly) {
      final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
      if (age > ttl) return null;
    }

    final out = <GridPointWeather>[];
    for (final m in data) {
      if (m is! Map) continue;
      final mm = Map<String, Object?>.from(m as Map);
      final lat = mm['lat'];
      final lng = mm['lng'];
      final condition = mm['condition'];
      if (lat is! num || lng is! num || condition is! Map) continue;
      out.add(
        GridPointWeather(
          latitude: lat.toDouble(),
          longitude: lng.toDouble(),
          condition: WeatherCondition.fromJson(Map<String, dynamic>.from(condition as Map)),
        ),
      );
    }
    return out;
  }

  void writeCache(List<GridPointWeather> list) {
    settings.put(key, {
      'ts': DateTime.now().millisecondsSinceEpoch,
      'data': list
          .map(
            (g) => {
              'lat': g.latitude,
              'lng': g.longitude,
              'condition': g.condition.toJson(),
            },
          )
          .toList(),
    });
  }

  final cached = readCache(freshOnly: true);
  if (cached != null) return cached;

  try {
    final result = await GetWeatherGrid(repo)(
      centerLat: req.centerLat,
      centerLng: req.centerLng,
      gridSize: req.gridSize,
      stepDegrees: req.stepDegrees,
    );
    writeCache(result);
    return result;
  } on AppFailure {
    final stale = readCache(freshOnly: false);
    if (stale != null) return stale;
    rethrow;
  } catch (e, st) {
    final stale = readCache(freshOnly: false);
    if (stale != null) return stale;
    throw AppFailure('Impossible de récupérer la grille météo.', cause: e, stackTrace: st);
  }
});
