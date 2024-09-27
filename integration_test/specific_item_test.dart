import 'package:ARRK/widgets/admin_employee_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ARRK/main.dart' as app;
import 'package:integration_test/integration_test.dart';
import 'package:ARRK/screens/add_employee_screen.dart';
void main() {
  group('App test', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('find a specific item', (tester) async {
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

final listFinder = find.byType(Scrollable);
final itemFinder = find.text('Cristiana');


    });
  });
}