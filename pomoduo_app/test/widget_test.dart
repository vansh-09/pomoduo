// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:pomoduo_demo/main.dart';

void main() {
  testWidgets('PomoDuo app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PomoDuoApp());

    // Verify that the splash screen shows initially
    expect(find.text('POMODUO'), findsOneWidget);
    expect(find.text('Focus • Work • Achieve'), findsOneWidget);

    // Wait for splash screen animation and navigation
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Should now be on the auth page (since no user is logged in)
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
