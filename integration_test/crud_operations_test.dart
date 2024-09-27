
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ARRK/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  group('Crud operations', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('Edit parking spots', (tester) async {
      //execute the app.main() function
      app.main();
      //wait until the app has settled ( the frame from before does not change anything)
      await tester.pumpAndSettle();


//Step 1: Admin login
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

//Step 2: Select Parking Spots button
      expect(find.byKey(const Key('crudOpParking')), findsOneWidget);
      final Finder crudParkingButton = find.byKey(const Key('crudOpParking'));
      await tester.tap(crudParkingButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
  //Step 3: Select the region
      expect(find.byKey(const Key('regionCrud')), findsOneWidget);
      final Finder regionDropDown = find.byKey(const Key('regionCrud'));
      await tester.tap(regionDropDown);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      final Finder parking = find.text('P3');
      await tester.tap(parking);
      await tester.pumpAndSettle(const Duration(seconds: 3));
   //Step 4: Choose the spot
      final Finder number = find.text('22');
      await tester.tap(number);

  //Step 5:Change the status
      expect(find.byKey(const Key('status')), findsOneWidget);
      final Finder status = find.byKey(const Key('status'));
      await tester.tap(status);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      final Finder chooseStatus = find.text('BLOCKED');
      await  tester.tap(chooseStatus);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byKey(const Key('editParkingSpots')), findsOneWidget);
      final Finder editButton = find.byKey(const Key('editParkingSpots'));
      await tester.tap(editButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      //Step 6: Choose the date

      expect(find.byKey(const Key('chooseDate')), findsOneWidget);
      final Finder chooseDate = find.byKey(const Key('chooseDate'));
      await tester.tap(chooseDate);
      await tester.pumpAndSettle(const Duration(seconds: 3));
       final Finder daySelected = find.text('12');
       await tester.tap(daySelected);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      final Finder confirmDay = find.text('OK');
      await tester.tap(confirmDay);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      //Step 7: Update the schedule
      expect(find.byKey( const Key('scheduleUpdate')), findsOneWidget);
      final Finder scheduleUpdate=find.byKey( const Key('scheduleUpdate'));
      await tester.tap(scheduleUpdate);
      await tester.pumpAndSettle(const Duration(seconds: 3));



    });
  });
}