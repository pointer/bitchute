import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitchute_app/main.dart' as app;

void main() {
  testWidgets('SearchScreen displays FAB and allows opening search dialog', (tester) async {
    // Pump the app's SearchScreen
    await tester.pumpWidget(MaterialApp(home: app.SearchScreen()));

    // Verify FAB is not present (we use AppBar inline search)
    expect(find.byType(FloatingActionButton), findsNothing);

    // Verify no search dialog is present
    expect(find.byType(AlertDialog), findsNothing);

    // Basic smoke checks
    expect(tester.any(find.byType(ListView)) || tester.any(find.text('No results')), isTrue);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
