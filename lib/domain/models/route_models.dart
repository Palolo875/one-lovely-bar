import 'package:freezed_annotation/freezed_annotation.dart';
import 'weather_condition.dart';

part 'route_models.freezed.dart';
part 'route_models.g.dart';

@freezed
class RoutePoint with _$RoutePoint {
  const factory RoutePoint({
    required double latitude,
    required double longitude,
    DateTime? timestamp,
    WeatherCondition? weather,
  }) = _RoutePoint;

  factory RoutePoint.fromJson(Map<String, dynamic> json) =>
      _$RoutePointFromJson(json);
}

@freezed
class RouteData with _$RouteData {
  const factory RouteData({
    required List<RoutePoint> points,
    required double distanceKm,
    required double durationMinutes,
    required String profile,
    String? gpxData,
  }) = _RouteData;

  factory RouteData.fromJson(Map<String, dynamic> json) =>
      _$RouteDataFromJson(json);
}
