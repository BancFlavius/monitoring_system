import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ARRK/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Step 1: Check-in', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check), findsOneWidget);
    final Finder checkButton = find.byIcon(Icons.check);
    await tester.tap(checkButton);

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.clear), findsOneWidget);
    final Finder clearButton = find.byIcon(Icons.clear);
    await tester.tap(clearButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));
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
    await tester.pumpAndSettle(const Duration(seconds: 10));
  });
  testWidgets('Step2: Search the employee', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.list), findsOneWidget);
    final Finder listButton = find.byIcon(Icons.list);
    await tester.tap(listButton);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('searchEmployee')), findsOneWidget);
    final Finder searchField = find.byKey(const Key('searchEmployee'));
    await tester.enterText(searchField, 'Bon');
    await tester.pumpAndSettle(const Duration (seconds: 2));
  });

  testWidgets('Step3: Make a reservation at the office', (tester) async {
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


    final Finder dayCalendar = find.text('28');
    await tester.tap(dayCalendar);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final Finder clickOk = find.text('OK');
    await tester.tap(clickOk);
    await tester.pumpAndSettle(const Duration(seconds: 2));




    expect(find.byKey(const Key('enterDigitsCode')), findsOneWidget);
    final Finder enterDigitsCode = find.byKey(const Key('enterDigitsCode'));
    await tester.enterText(enterDigitsCode, '1267');

   await tester.testTextInput.receiveAction(TextInputAction.done);
   await tester.pump();

    expect(find.byKey(const Key('verifyCodeButton')), findsOneWidget);
    final Finder verifyButton = find.byKey(const Key('verifyCodeButton'));
    await tester.tap(verifyButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.byKey(const Key('confirmResButton')), findsOneWidget);
    final Finder confirmRes = find.byKey(const Key('confirmResButton'));
    await tester.tap(confirmRes);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.byKey(const Key('confirmedButton')), findsOneWidget);
    final Finder confirmedButton = find.byKey(const Key('confirmedButton'));
    await tester.tap(confirmedButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

testWidgets('Step 4: Check-out', (tester) async{
  app.main();
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

  expect(find.byKey(const Key ('checkoutButton')), findsOneWidget);
  final Finder checkOutButton =find.byKey(const Key ('checkoutButton'));
  await tester.tap(checkOutButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));



});


}