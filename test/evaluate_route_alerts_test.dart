import 'package:flutter_test/flutter_test.dart';
import 'package:weathernav/domain/models/route_alert.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/domain/usecases/evaluate_route_alerts.dart';

void main() {
  test('EvaluateRouteAlerts returns precip alert when threshold is exceeded', () {
    const usecase = EvaluateRouteAlerts();

    const profile = UserProfile(
      id: 't',
      name: 'Test',
      type: ProfileType.universal,
      alertThresholds: {'precipitation_mm': 1.0},
    );

    final timeline = [
      WeatherCondition(
        temperature: 10,
        precipitation: 2,
        windSpeed: 5,
        windDirection: 0,
        weatherCode: 61,
        timestamp: DateTime(2026, 1, 1, 10),
      ),
    ];

    final alerts = usecase(profile: profile, timeline: timeline);
    expect(alerts.where((a) => a.type == RouteAlertType.precipitation), isNotEmpty);
  });

  test('EvaluateRouteAlerts returns no alert when thresholds are not exceeded', () {
    const usecase = EvaluateRouteAlerts();

    const profile = UserProfile(
      id: 't',
      name: 'Test',
      type: ProfileType.universal,
      alertThresholds: {
        'precipitation_mm': 5.0,
        'wind_kmh': 120.0,
        'temp_low_c': -20.0,
        'temp_high_c': 60.0,
      },
    );

    final timeline = [
      WeatherCondition(
        temperature: 15,
        precipitation: 0.2,
        windSpeed: 10,
        windDirection: 0,
        weatherCode: 1,
        timestamp: DateTime(2026, 1, 1, 10),
      ),
      WeatherCondition(
        temperature: 16,
        precipitation: 0,
        windSpeed: 12,
        windDirection: 0,
        weatherCode: 2,
        timestamp: DateTime(2026, 1, 1, 11),
      ),
    ];

    final alerts = usecase(profile: profile, timeline: timeline);
    expect(alerts, isEmpty);
  });
}
