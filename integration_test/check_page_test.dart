import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ARRK/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  group('Check-in Page', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('check-in', (tester) async {
      //execute the app.main() function
      app.main();
      //wait until the app has settled ( the frame from before does not change anything)
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
      final Finder checkButton = find.byIcon(Icons.check);
      await tester.tap(checkButton);
      await tester.pumpAndSettle();


      expect(find.text('1'), findsOneWidget);
      final Finder digit1 = find.text('1');
      await tester.tap(digit1);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('2'), findsOneWidget);
      final Finder digit2 = find.text('2');
      await tester.tap(digit2);


      await tester.pumpAndSettle(const Duration(seconds: 2));



      expect(find.text('6'), findsOneWidget);
      final Finder digit3 = find.text('6');
      await tester.tap(digit3);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('7'), findsOneWidget);
      final Finder digit4 = find.text('7');
      await tester.tap(digit4);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byKey(const Key('checkinButton')), findsOneWidget);
      final Finder checkIn = find.byKey(const Key('checkinButton'));
      await tester.tap(checkIn);
      await tester.pumpAndSettle(const Duration(seconds: 2));








    });
  });
}

      /*

      expect(find.byKey(const Key('enterDigits')), findsWidgets);
      final Finder digitsButtons = find.byKey(const Key('enterDigits'));

      await tester.tap(digitsButtons);

      await tester.pumpAndSettle(Duration(seconds: 2));

      expect(find.byKey(const Key('checkinButton')), findsOneWidget);
      final Finder checkIn = find.byKey(const Key('checkinButton'));
      await tester.tap(checkIn);
      await tester.pumpAndSettle(Duration(seconds: 4));


      expect(find.byIcon(Icons.check), findsOneWidget);
      final Finder checkButton1 = find.byIcon(Icons.check);
      await tester.tap(checkButton1);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('enterDigits')), findsWidgets);
      final Finder digitsButtons1 = find.byKey(const Key('enterDigits'));

      await tester.tap(digitsButtons1);

      await tester.pumpAndSettle(Duration(seconds: 2));
      expect(find.byKey(const Key('checkoutButton')), findsOneWidget);
      final Finder checkIn1 = find.byKey(const Key('checkoutButton'));
      await tester.tap(checkIn1);
      await tester.pumpAndSettle(Duration(seconds: 4));
    });
  });
}

       */
