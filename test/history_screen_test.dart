import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bitchute_browser/services/history_service.dart';
import 'package:bitchute_browser/models/video.dart';
import 'package:bitchute_browser/screens/history_screen.dart';

void main() {
  testWidgets('HistoryScreen shows entries and allows clearing', (tester) async {
    final service = HistoryService();
    final sample = Video(title: 'H1', author: 'A', username: 'u', url: 'https://x', thumbnail: null);
    service.add(sample);

    await tester.pumpWidget(MultiProvider(providers: [ChangeNotifierProvider.value(value: service)], child: MaterialApp(home: const HistoryScreen())));

    await tester.pumpAndSettle();

    expect(find.text('H1'), findsOneWidget);

    // Tap clear
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('No viewing history'), findsOneWidget);
  });
}
