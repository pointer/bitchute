// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitchute_browser/services/api_service.dart';

import 'package:bitchute_browser/main.dart';

void main() {
  testWidgets('Search screen basic UI', (WidgetTester tester) async {
    // Build our app with autoLoad disabled to check the empty state.
    // SearchScreen is a standalone widget that doesn't require auth context.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchScreen(api: ApiService(), autoLoad: false),
        ),
      ),
    );

    // Verify search FAB and empty state are present.
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // With no results yet, the UI should show the empty state.
    expect(find.text('No results'), findsOneWidget);
  });
}
