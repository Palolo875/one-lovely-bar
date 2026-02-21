import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/route_models.dart';
import '../../domain/models/weather_condition.dart';
import '../../domain/usecases/get_weather_timeline_for_route_eta.dart';
import 'repository_providers.dart';

class WeatherTimelineEtaRequest {
  final RouteData route;
  final DateTime departureTime;

  const WeatherTimelineEtaRequest({required this.route, required this.departureTime});

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
