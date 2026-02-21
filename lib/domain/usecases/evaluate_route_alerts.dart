import '../models/route_alert.dart';
import '../models/user_profile.dart';
import '../models/weather_condition.dart';

class EvaluateRouteAlerts {
  const EvaluateRouteAlerts();

  List<RouteAlert> call({
    required UserProfile profile,
    required List<WeatherCondition> timeline,
  }) {
    if (timeline.isEmpty) return const <RouteAlert>[];

    final thresholds = profile.alertThresholds;

    // Basic defaults (can be overridden per profile via alertThresholds)
    final precipMmThreshold = thresholds['precipitation_mm'] ?? 1.0;
    final windKmhThreshold = thresholds['wind_kmh'] ?? 35.0;
    final tempLowThreshold = thresholds['temp_low_c'] ?? -2.0;
    final tempHighThreshold = thresholds['temp_high_c'] ?? 35.0;

    final maxPrecip = timeline.map((c) => c.precipitation).fold<double>(0, (a, b) => b > a ? b : a);
    final maxWind = timeline.map((c) => c.windSpeed).fold<double>(0, (a, b) => b > a ? b : a);
    final minTemp = timeline.map((c) => c.temperature).fold<double>(timeline.first.temperature, (a, b) => b < a ? b : a);
    final maxTemp = timeline.map((c) => c.temperature).fold<double>(timeline.first.temperature, (a, b) => b > a ? b : a);

    final alerts = <RouteAlert>[];

    if (maxPrecip >= precipMmThreshold) {
      alerts.add(
        RouteAlert(
          type: RouteAlertType.precipitation,
          title: 'Pluie sur le trajet',
          message: 'Jusqu’à ${maxPrecip.toStringAsFixed(1)} mm/h prévus sur l’itinéraire.',
        ),
      );
    }

    if (maxWind >= windKmhThreshold) {
      alerts.add(
        RouteAlert(
          type: RouteAlertType.wind,
          title: 'Vent fort',
          message: 'Jusqu’à ${maxWind.toStringAsFixed(0)} km/h sur le trajet.',
        ),
      );
    }

    if (minTemp <= tempLowThreshold) {
      alerts.add(
        RouteAlert(
          type: RouteAlertType.temperatureLow,
          title: 'Risque de gel',
          message: 'Température minimale estimée ${minTemp.toStringAsFixed(0)}°C.',
        ),
      );
    }

    if (maxTemp >= tempHighThreshold) {
      alerts.add(
        RouteAlert(
          type: RouteAlertType.temperatureHigh,
          title: 'Chaleur élevée',
          message: 'Température maximale estimée ${maxTemp.toStringAsFixed(0)}°C.',
        ),
      );
    }

    return alerts;
  }
}
