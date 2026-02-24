import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:weathernav/core/theme/app_tokens.dart';
import 'package:weathernav/domain/models/weather_condition.dart';

class WeatherTimeline extends StatelessWidget {
  const WeatherTimeline({required this.conditions, super.key});
  final List<WeatherCondition> conditions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: conditions.length,
        itemBuilder: (context, index) {
          final condition = conditions[index];
          final color = _getConditionColor(scheme, condition.weatherCode);
          return Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: color.withAlpha(51)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  DateFormat('HH:mm').format(condition.timestamp),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                Icon(_getWeatherIcon(condition.weatherCode), color: color),
                Text(
                  '${condition.temperature.round()}°',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${condition.windSpeed.round()} km/h',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getConditionColor(ColorScheme scheme, int code) {
    if (code == 0) return scheme.primary; // Clear
    if (code < 50) return scheme.onSurfaceVariant; // Cloudy
    if (code < 70) return scheme.tertiary; // Rain
    return scheme.error; // Severe
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) return LucideIcons.sun;
    if (code < 3) return LucideIcons.cloudSun;
    if (code < 50) return LucideIcons.cloud;
    if (code < 70) return LucideIcons.cloudRain;
    return LucideIcons.cloudLightning;
  }
}
