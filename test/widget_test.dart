import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernav/main.dart';

void main() {
  testWidgets('App should load Home Screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: WeatherNavApp()));
    expect(find.text('Où allez-vous ?'), findsOneWidget);
  });
}
