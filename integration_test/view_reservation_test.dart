import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ARRK/main.dart' as app;
import 'package:flutter/material.dart';
void main() {
  group('Reservation parking test', ()
  {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    testWidgets('view reservations', (tester) async {

      app.main();
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home_repair_service_rounded), findsOneWidget);
      final Finder resTab = find.byIcon(Icons.home_repair_service_rounded);
      await tester.tap(resTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byKey(const Key('enterDigitsCode')), findsOneWidget);
      final Finder enterDigitsCode = find.byKey(const Key('enterDigitsCode'));
      await tester.enterText(enterDigitsCode, '3002');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byKey(const Key('verifyCodeButton')), findsOneWidget);
      final Finder verifyButton = find.byKey(const Key('verifyCodeButton'));
      await tester.tap(verifyButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      final Finder viewResButton = find.byIcon(Icons.calendar_today);
      await tester.tap(viewResButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));



    });
  });
}