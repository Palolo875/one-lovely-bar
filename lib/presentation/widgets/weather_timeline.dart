import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:weathernav/domain/models/weather_condition.dart';

class WeatherTimeline extends StatelessWidget {

  const WeatherTimeline({super.key, required this.conditions});
  final List<WeatherCondition> conditions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: conditions.length,
        itemBuilder: (context, index) {
          final condition = conditions[index];
          return Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _getConditionColor(condition.weatherCode).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getConditionColor(condition.weatherCode).withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  DateFormat('HH:mm').format(condition.timestamp),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Icon(
                  _getWeatherIcon(condition.weatherCode),
                  color: _getConditionColor(condition.weatherCode),
                ),
                Text(
                  '${condition.temperature.round()}°',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${condition.windSpeed.round()} km/h',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getConditionColor(int code) {
    if (code == 0) return Colors.blue; // Clear
    if (code < 50) return Colors.grey; // Cloudy
    if (code < 70) return Colors.orange; // Rain
    return Colors.red; // Severe
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) return LucideIcons.sun;
    if (code < 3) return LucideIcons.cloudSun;
    if (code < 50) return LucideIcons.cloud;
    if (code < 70) return LucideIcons.cloudRain;
    return LucideIcons.cloudLightning;
  }
}
