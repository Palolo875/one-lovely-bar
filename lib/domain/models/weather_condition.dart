import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_condition.freezed.dart';
part 'weather_condition.g.dart';

@freezed
abstract class WeatherCondition with _$WeatherCondition {
  const factory WeatherCondition({
    required double temperature,
    required double precipitation,
    required double windSpeed,
    required double windDirection,
    required int weatherCode,
    required DateTime timestamp,
    double? visibility,
    double? uvIndex,
    double? cloudCover,
    double? airQuality,
  }) = _WeatherCondition;

  factory WeatherCondition.fromJson(Map<String, dynamic> json) =>
      _$WeatherConditionFromJson(json);
}
