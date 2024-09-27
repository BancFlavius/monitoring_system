

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ARRK/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  group('App test', () {

IntegrationTestWidgetsFlutterBinding.ensureInitialized();

testWidgets('admin login', (tester) async {

  //execute the app.main() function
  app.main();
  //wait until the app has settled ( the frame from before does not change anything)
await tester.pumpAndSettle();


//verify the admin button
expect(find.text('Admin Login'), findsOneWidget);
final Finder adminButton = find.text('Admin Login');
await tester.tap(adminButton);

await tester.pumpAndSettle(Duration(seconds: 4));

expect(find.byKey(const Key('adminPassword')), findsOneWidget);
final Finder passwordAdmin = find.byKey(const Key('adminPassword'));
await tester.enterText(passwordAdmin, 'admin1234');
await tester.pumpAndSettle(const Duration(seconds: 4));
await tester.tap(find.byKey(const Key('authenticateAdmin')));
await tester.pumpAndSettle(const Duration(seconds: 3));



expect(find.byIcon(Icons.add), findsOneWidget);
final Finder addEmployee = find.byIcon(Icons.add);
await tester.tap(addEmployee);
await tester.pumpAndSettle(const Duration(seconds: 3));

expect(find.byKey(const Key('nameEmployee')), findsOneWidget);
final Finder nameEmployee = find.byKey(const Key('nameEmployee'));
await tester.enterText(nameEmployee, 'Test Name');
await tester.pumpAndSettle(const Duration(seconds: 2));

expect(find.byKey(const Key('codeEmployee')), findsOneWidget);
final Finder codeEmployee = find.byKey(const Key('codeEmployee'));
await tester.enterText(codeEmployee, '1998');
await tester.pumpAndSettle(const Duration(seconds: 2));


expect(find.byKey(const Key('reportsToManager')), findsOneWidget);
final Finder reportsField= find.byKey(const Key('reportsToManager'));
await tester.tap(reportsField);
await tester.pumpAndSettle(const Duration(seconds: 2));
 final Finder managerName = find.text('Cimpean Andrei');
 await tester.tap(managerName);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.byKey(const Key('addEmployee')), findsOneWidget);
  final Finder addEmployeeButton = find.byKey(const Key('addEmployee'));

  await tester.tap(addEmployeeButton);
  await tester.pumpAndSettle(const Duration(seconds: 10));


  expect(find.byKey(const Key('filterByManagersHomeTab')), findsOneWidget);
  final Finder dropDownManagers = find.byKey(const Key('filterByManagersHomeTab'));
  await tester.tap(dropDownManagers);
  await tester.pumpAndSettle(const Duration(seconds: 3));
  final Finder name=find.text('Cimpean Andrei');
  await tester.tap(name);
  await tester.pumpAndSettle(const Duration(seconds: 2));




  });

  });

}












