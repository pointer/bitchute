import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitchute_browser/main.dart' as app;
import 'package:bitchute_browser/widgets/video_tile.dart';

void main() {
  testWidgets('SearchScreen performs a live search and shows results or an error', (tester) async {
    // Pump the app's SearchScreen
    await tester.pumpWidget(MaterialApp(home: app.SearchScreen()));

    // Enter a sample query and tap Search
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'flutter');
    await tester.tap(find.text('Search'));

    // Allow network and UI to settle (may take a few seconds)
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Check for results or an error message
    final tiles = find.byType(VideoTile);
    if (tiles.evaluate().isNotEmpty) {
      final titles = tiles.evaluate().map((e) => (e.widget as VideoTile).video.title).take(5).toList();
      // Print sample titles to test output so we can verify live results in logs
      print('Found ${titles.length} results: ${titles.join(', ')}');
      expect(titles.isNotEmpty, true);
    } else {
      final error = find.textContaining('Error:');
      expect(error, findsOneWidget);
      print('Search resulted in an error widget.');
    }
  }, timeout: const Timeout(Duration(seconds: 60)));
}
