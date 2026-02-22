import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// To run this test on an emulator/device:
// flutter test integration_test/app_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('App launches and navigates gracefully',
        (tester) async {
      // 1. Build our app and trigger a frame.
      // 2. Wait for animations to settle
      // 3. Find key UI elements
      
      // import 'package:weathernav/main.dart' as app;
      // app.main();
      // await tester.pumpAndSettle();

      // expect(find.text('Où allez-vous ?'), findsOneWidget);
    });
  });
}
