import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitchute_browser/main.dart' as app;
import 'package:bitchute_browser/widgets/video_tile.dart';

void main() {
  testWidgets('SearchScreen displays FAB and allows opening search dialog', (tester) async {
    // Pump the app's SearchScreen
    await tester.pumpWidget(MaterialApp(home: app.SearchScreen()));

    // Verify FAB is visible
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Tap FAB to open search dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify search dialog appeared with text field and buttons
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Search'), findsWidgets);
    expect(find.text('Cancel'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Verify dialog is closed
    expect(find.byType(AlertDialog), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
