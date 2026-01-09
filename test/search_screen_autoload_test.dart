import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitchute_browser/main.dart';
import 'package:bitchute_browser/models/video.dart';
import 'package:bitchute_browser/services/api_service.dart';
import 'package:shimmer/shimmer.dart';

import 'package:http/http.dart' as http;

class FakeApiService extends ApiService {
  final List<Video> result;
  final Duration delay;

  FakeApiService({required this.result, this.delay = const Duration(milliseconds: 200)}) : super(client: http.Client());

  @override
  Future<List<Video>> search(String query, {int limit = 50}) => Future.delayed(delay, () => result);
}

void main() {
  testWidgets('auto-loads home feed on open and shows results', (tester) async {
    final sample = [
      Video(title: 'Auto1', author: 'A', username: 'u1', url: 'https://x', thumbnail: null),
    ];

    final fake = FakeApiService(result: sample, delay: const Duration(milliseconds: 150));

    await tester.pumpWidget(MaterialApp(home: SearchScreen(api: fake, autoLoad: true)));

    // initial frame should show loading shimmer
    await tester.pump();
    expect(find.byType(Shimmer), findsWidgets);

    // wait for the fake api
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // after load we should see the result title
    expect(find.text('Auto1'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });
}
