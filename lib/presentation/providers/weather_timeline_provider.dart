import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/route_models.dart';
import '../../domain/models/weather_condition.dart';
import '../../domain/usecases/get_weather_timeline_for_route.dart';
import 'repository_providers.dart';

part 'weather_timeline_provider.g.dart';

@riverpod
Future<List<WeatherCondition>> weatherTimeline(WeatherTimelineRef ref, RouteData route) async {
  final weatherRepo = ref.watch(weatherRepositoryProvider);
  return GetWeatherTimelineForRoute(weatherRepo)(route);
}
