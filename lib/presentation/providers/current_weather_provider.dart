import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/domain/usecases/get_current_weather.dart';
import 'package:weathernav/presentation/providers/repository_providers.dart';

class LatLngRequest {

  const LatLngRequest({required this.lat, required this.lng});
  final double lat;
  final double lng;

  @override
  bool operator ==(Object other) {
    return other is LatLngRequest && other.lat == lat && other.lng == lng;
  }

  @override
  int get hashCode => Object.hash(lat, lng);
}

final currentWeatherProvider = FutureProvider.autoDispose.family<WeatherCondition, LatLngRequest>((ref, req) async {
  final repo = ref.watch(weatherRepositoryProvider);
  return GetCurrentWeather(repo)(req.lat, req.lng);
});
