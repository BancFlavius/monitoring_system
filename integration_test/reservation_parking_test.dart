
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ARRK/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  group('Reservation parking test with parking', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('reserve parking spot ', (tester) async {
      app.main();

      //select the tab
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home_repair_service_rounded), findsOneWidget);
      final Finder resTab = find.byIcon(Icons.home_repair_service_rounded);
      await tester.tap(resTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      //select the date
      expect(find.byKey(const Key('selectFloor')), findsOneWidget);
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

      final Finder dayCalendar = find.text('11');
      await tester.tap(dayCalendar);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      final Finder clickOk = find.text('OK');
      await tester.tap(clickOk);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      //tap on Parking Spot button
      expect(find.byKey(const Key('reserveParkingSpot')), findsOneWidget);
      final Finder reserveParking = find.byKey(const Key('reserveParkingSpot'));
      await tester.tap(reserveParking);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      //choose region
      expect(find.byKey(const Key('chooseRegion')), findsOneWidget);
      final Finder selectRegion = find.byKey(const Key('chooseRegion'));
      await tester.tap(selectRegion);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      final Finder chooseRegion = find.text('P2');
      await tester.tap(chooseRegion);

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('24'), findsOneWidget);
      final Finder selectNumber = find.text('24');
      await tester.tap(selectNumber);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byKey(const Key('confirmButtonParking')), findsOneWidget);
      final Finder confirmButtonParking =
      find.byKey(const Key('confirmButtonParking'));
      await tester.tap(confirmButtonParking);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byKey(const Key('enterDigitsCode')), findsOneWidget);
      final Finder enterDigitsCode = find.byKey(const Key('enterDigitsCode'));
      await tester.enterText(enterDigitsCode, '3002');
//simulate the enter button on keyboard
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.pumpAndSettle(const Duration(seconds:2));

      expect(find.byKey(const Key('verifyCodeButton')), findsOneWidget);
      final Finder verifyButton = find.byKey(const Key('verifyCodeButton'));
      await tester.tap(verifyButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));


      expect(find.byKey(const Key('confirmResButton')), findsOneWidget);
      final Finder confirmRes = find.byKey(const Key('confirmResButton'));
      await tester.tap(confirmRes);

      await tester.pumpAndSettle(const Duration(seconds: 2));






    });
  });
}
