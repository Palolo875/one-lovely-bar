import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/domain/usecases/get_forecast.dart';
import 'package:weathernav/presentation/providers/current_weather_provider.dart';
import 'package:weathernav/presentation/providers/repository_providers.dart';

class ForecastRequest extends LatLngRequest {

  const ForecastRequest({required super.lat, required super.lng, this.days = 7});
  final int days;

  @override
  bool operator ==(Object other) {
    return other is ForecastRequest && other.lat == lat && other.lng == lng && other.days == days;
  }

  @override
  int get hashCode => Object.hash(lat, lng, days);
}

final forecastProvider = FutureProvider.autoDispose.family<List<WeatherCondition>, ForecastRequest>((ref, req) async {
  final repo = ref.watch(weatherRepositoryProvider);
  return GetForecast(repo)(req.lat, req.lng, days: req.days);
});
