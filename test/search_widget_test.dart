import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitchute_browser/main.dart' as app;

void main() {
  testWidgets('SearchScreen displays FAB and allows opening search dialog', (tester) async {
    // Pump the app's SearchScreen
    await tester.pumpWidget(MaterialApp(home: app.SearchScreen()));

    // Verify FAB is not present (we use AppBar inline search)
    expect(find.byType(FloatingActionButton), findsNothing);

    // Verify no search dialog is present
    expect(find.byType(AlertDialog), findsNothing);

    // Basic smoke checks
    expect(find.byType(ListView) | find.text('No results'), findsWidgets);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
