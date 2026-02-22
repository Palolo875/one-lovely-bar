import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/presentation/widgets/weather_timeline.dart';

void main() {
  testWidgets('WeatherTimeline renders items and time labels', (WidgetTester tester) async {
    final conditions = [
      WeatherCondition(
        temperature: 10,
        precipitation: 0,
        windSpeed: 5,
        windDirection: 0,
        weatherCode: 0,
        timestamp: DateTime(2026, 1, 1, 10),
      ),
      WeatherCondition(
        temperature: 12,
        precipitation: 0,
        windSpeed: 6,
        windDirection: 0,
        weatherCode: 2,
        timestamp: DateTime(2026, 1, 1, 11),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherTimeline(conditions: conditions),
        ),
      ),
    );

    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('11:00'), findsOneWidget);
    expect(find.text('10°'), findsOneWidget);
    expect(find.text('12°'), findsOneWidget);
  });
}
