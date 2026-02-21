import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/route_models.dart';
import '../../domain/models/weather_condition.dart';
import 'repository_providers.dart';

part 'weather_timeline_provider.g.dart';

@riverpod
Future<List<WeatherCondition>> weatherTimeline(WeatherTimelineRef ref, RouteData route) async {
  final weatherRepo = ref.watch(weatherRepositoryProvider);

  // We take points every N km or N minutes to not overload the API
  // For the MVP, we just take 5 points along the route
  final List<Map<String, dynamic>> pointsToFetch = [];
  if (route.points.length <= 5) {
    for (var p in route.points) {
      pointsToFetch.add({'lat': p.latitude, 'lng': p.longitude});
    }
  } else {
    // Basic sampling
    for (int i = 0; i < 5; i++) {
      final index = (i * (route.points.length - 1) / 4).floor();
      final p = route.points[index];
      pointsToFetch.add({'lat': p.latitude, 'lng': p.longitude});
    }
  }

  return await weatherRepo.getBatchWeather(pointsToFetch);
}
