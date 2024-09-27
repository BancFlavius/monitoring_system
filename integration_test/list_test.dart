import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ARRK/main.dart' as app;
import 'package:integration_test/integration_test.dart';
import 'package:ARRK/tabs/employee_list_tab.dart';

void main() {
  group('List Page', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('search employee in office', (tester) async {
      //execute the app.main() function
      app.main();
      //wait until the app has settled ( the frame from before does not change anything)
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.list), findsOneWidget);
      final Finder listButton = find.byIcon(Icons.list);
      await tester.tap(listButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('searchEmployee')), findsOneWidget);
      final Finder searchField = find.byKey(const Key('searchEmployee'));
      await tester.enterText(searchField, 'Csil');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('searchButton')), findsOneWidget);
      final Finder searchButton = find.byKey(const Key('searchButton'));
      await tester.tap(searchButton);
      await tester.pumpAndSettle(Duration(seconds: 2));




    expect(find.byKey(const Key('allManagersFilter')), findsOneWidget);
    final Finder managerFilter = find.byKey(const Key('allManagersFilter'));
    await tester.tap(managerFilter);
    await tester.pumpAndSettle(Duration(seconds: 2));

    final Finder managerName = find.text('Cimpean Andrei');
    await tester.tap(managerName);
        await tester.pumpAndSettle(Duration(seconds: 2));











});
    testWidgets('filter by manager', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.list), findsOneWidget);
      final Finder listButton = find.byIcon(Icons.list);
      await tester.tap(listButton);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('allManagersFilter')), findsOneWidget);
      final Finder managerFilter = find.byKey(const Key('allManagersFilter'));
      await tester.tap(managerFilter);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final Finder managerName = find.text('Dumitru Iulian');
      await tester.tap(managerName);
      await tester.pumpAndSettle(const Duration(seconds: 2));



    });
});

}
