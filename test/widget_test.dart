// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ARRK/widgets/view_reservations.dart';
void main() {
  testWidgets('find a text widget', (tester) async {
await tester.pumpWidget(const MaterialApp(
  home: Scaffold(
    body: Text('Verify Code'),
  ),
));
expect(find.text('Verify Code'), findsOneWidget);
  });


  testWidgets('find a text widget', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Text('Cancel Code'),
      ),
    ));
    expect(find.text('Cancel Code'), findsOneWidget);
  });


  testWidgets('finds a widget using a key', (tester) async {
    const testKey1=Key('adminLoginButton');
    await tester.pumpWidget(MaterialApp(key:testKey1, home:Container()));
    expect(find.byKey(testKey1), findsOneWidget);
  });

  testWidgets('finds a widget using a key', (tester) async {
    const testKey2=Key('checkinButton');
    await tester.pumpWidget(MaterialApp(key:testKey2, home:Container()));
    expect(find.byKey(testKey2), findsOneWidget);
  });



}