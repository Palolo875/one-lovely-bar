import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weathernav/domain/models/route_models.dart';
import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/domain/usecases/get_weather_timeline_for_route.dart';
import 'package:weathernav/presentation/providers/repository_providers.dart';

part 'weather_timeline_provider.g.dart';

@riverpod
Future<List<WeatherCondition>> weatherTimeline(Ref ref, RouteData route) async {
  final weatherRepo = ref.watch(weatherRepositoryProvider);
  return GetWeatherTimelineForRoute(weatherRepo)(route);
}
