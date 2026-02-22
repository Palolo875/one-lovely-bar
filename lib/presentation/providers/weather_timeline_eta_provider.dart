import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernav/domain/models/route_models.dart';
import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/domain/usecases/get_weather_timeline_for_route_eta.dart';
import 'package:weathernav/presentation/providers/repository_providers.dart';

class WeatherTimelineEtaRequest {

  const WeatherTimelineEtaRequest({required this.route, required this.departureTime});
  final RouteData route;
  final DateTime departureTime;

  @override
  bool operator ==(Object other) {
    return other is WeatherTimelineEtaRequest &&
        other.route == route &&
        other.departureTime == departureTime;
  }

  @override
  int get hashCode => Object.hash(route, departureTime);
}

final weatherTimelineEtaProvider = FutureProvider.autoDispose.family<List<WeatherCondition>, WeatherTimelineEtaRequest>((ref, req) async {
  final repo = ref.watch(weatherRepositoryProvider);
  return GetWeatherTimelineForRouteEta(repo)(route: req.route, departureTime: req.departureTime);
});
