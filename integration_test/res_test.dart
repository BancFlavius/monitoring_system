import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ARRK/main.dart' as app;
import 'package:integration_test/integration_test.dart';


void main() {
  group('Reservation tab test without parking', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('confirm reservation ', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home_repair_service_rounded), findsOneWidget);
      final Finder resTab = find.byIcon(Icons.home_repair_service_rounded);
      await tester.tap(resTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byKey(const Key ('selectFloor')), findsOneWidget);
      final Finder selectFloor = find.byKey(const Key('selectFloor'));
      await tester.tap(selectFloor);
      await tester.pumpAndSettle();
      final Finder chooseFloor = find.text('5');
      await tester.tap(chooseFloor);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byKey(const Key('chooseDate')), findsOneWidget);
      final Finder chooseDate = find.byKey(const Key('chooseDate'));
      await tester.tap(chooseDate);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder dayCalendar = find.text('14');
      await tester.tap(dayCalendar);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      final Finder clickOk = find.text('OK');
      await tester.tap(clickOk);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byKey(const Key('enterDigitsCode')), findsOneWidget);
      final Finder enterDigitsCode = find.byKey(const Key('enterDigitsCode'));
      await tester.enterText(enterDigitsCode, '3002');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byKey(const Key('verifyCodeButton')), findsOneWidget);
      final Finder verifyButton = find.byKey(const Key('verifyCodeButton'));
      await tester.tap(verifyButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));


      expect(find.byKey(const Key('confirmResButton')), findsOneWidget);
      final Finder confirmRes = find.byKey(const Key('confirmResButton'));
      await tester.tap(confirmRes);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byKey(const Key('confirmedButton')), findsOneWidget);
      final Finder confirmedButton = find.byKey(const Key('confirmedButton'));
      await tester.tap(confirmedButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));







    });
  });
}
