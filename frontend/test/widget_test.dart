// Flutter widget test
// Find child widgets in the widget tree, read text and verify that the values of widget properties are correct.
// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Login button renders and responds to tap', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Look for the Login button by its text
    final loginButton = find.text('Login');

    // Make sure the button appears
    expect(loginButton, findsOneWidget);

    // Tap the button
    await tester.tap(loginButton);
    await tester.pump(); // triggers a rebuild, if any
  });
}