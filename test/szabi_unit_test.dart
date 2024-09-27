// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:ARRK/tabs/check_in_tab.dart';
//
// void main() {
//   setUpAll(() async {
//     await Firebase.initializeApp();
//   });
//
//   group('CheckInTab', () {
//     // Test case for verifying the check-in functionality
//     testWidgets('Check-in button should trigger check-in process', (WidgetTester tester) async {
//
//       // Create a mock function for navigation
//       bool navigateToEmployeeListTabCalled = false;
//       void navigateToEmployeeListTab() {
//         navigateToEmployeeListTabCalled = true;
//       }
//
//       // Build the CheckInTab widget
//       await tester.pumpWidget(
//         MaterialApp(
//           home: CheckInTab(
//             navigateToEmployeeListTab: navigateToEmployeeListTab,
//           ),
//         ),
//       );
//
//       // Simulate pressing the buttons to enter the code
//       await tester.tap(find.widgetWithText(ElevatedButton, '1'));
//       await tester.tap(find.widgetWithText(ElevatedButton, '2'));
//       await tester.tap(find.widgetWithText(ElevatedButton, '3'));
//       await tester.tap(find.widgetWithText(ElevatedButton, '4'));
//       await tester.pumpAndSettle();
//
//       // Tap the check-in button
//       await tester.tap(find.text('Check-in'));
//       await tester.pumpAndSettle();
//
//       //expect(find.text('Hi, [Employee Name]! Welcome.'), findsOneWidget);
//       // Verify that the navigateToEmployeeListTab function was called
//       expect(navigateToEmployeeListTabCalled, true);
//
//       // TODO: Add additional assertions based on your application's behavior
//     });
//
//     // Test case for verifying the check-out functionality
//     testWidgets('Check-out button should trigger check-out process', (WidgetTester tester) async {
//       // Create a mock function for navigation
//       bool navigateToEmployeeListTabCalled = false;
//       void navigateToEmployeeListTab() {
//         navigateToEmployeeListTabCalled = true;
//       }
//
//       // Build the CheckInTab widget
//       await tester.pumpWidget(
//         MaterialApp(
//           home: CheckInTab(
//             navigateToEmployeeListTab: navigateToEmployeeListTab,
//           ),
//         ),
//       );
//
//       // Simulate pressing the buttons to enter the code
//       await tester.tap(find.widgetWithText(ElevatedButton, '1'));
//       await tester.tap(find.widgetWithText(ElevatedButton, '2'));
//       await tester.tap(find.widgetWithText(ElevatedButton, '3'));
//       await tester.tap(find.widgetWithText(ElevatedButton, '4'));
//       await tester.pumpAndSettle();
//
//       // Tap the check-out button
//       await tester.tap(find.text('Check-out'));
//       await tester.pumpAndSettle();
//
//       // Verify that the navigateToEmployeeListTab function was called
//       expect(navigateToEmployeeListTabCalled, true);
//
//       // TODO: Add additional assertions based on your application's behavior
//     });
//
//     // TODO: Add more test cases for different scenarios and edge cases
//   });
// }
// // flutter test