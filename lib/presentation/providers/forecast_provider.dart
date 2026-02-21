import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/weather_condition.dart';
import '../../domain/usecases/get_forecast.dart';
import 'current_weather_provider.dart';
import 'repository_providers.dart';

class ForecastRequest extends LatLngRequest {
  final int days;

  const ForecastRequest({required super.lat, required super.lng, this.days = 7});

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
