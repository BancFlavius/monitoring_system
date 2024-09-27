import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ARRK/main.dart' as app;
import 'package:integration_test/integration_test.dart';


void main() {
  group('Show parking', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets(' Show parking spots', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home_repair_service_rounded), findsOneWidget);
      final Finder resTab = find.byIcon(Icons.home_repair_service_rounded);
      await tester.tap(resTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

   expect(find.byKey(const Key('reserveParkingSpot')), findsOneWidget);
    final Finder reserveParking = find.byKey(const Key('reserveParkingSpot'));
    await tester.tap(reserveParking);

    await tester.pumpAndSettle(const Duration(seconds: 2));

//show P1

    expect(find.byKey(const Key('showP1')), findsOneWidget);
    final Finder showP1Button = find.byKey(const Key('showP1'));
    await tester.tap(showP1Button);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(const Duration(seconds: 3));


//show P2
      expect(find.byKey(const Key('showP2')), findsOneWidget);
      final Finder showP2Button = find.byKey(const Key('showP2'));
      await tester.tap(showP2Button);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(const Duration(seconds: 3));


//show P3
      expect(find.byKey(const Key('showP3')), findsOneWidget);
      final Finder showP3Button = find.byKey(const Key('showP3'));
      await tester.tap(showP3Button);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      //show detail P3
      expect(find.byKey(const Key('detailP3')), findsOneWidget);
      final Finder detailP3Button = find.byKey(const Key('detailP3'));
      await tester.tap(detailP3Button);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(const Duration(seconds: 3));




    });
  });
}
