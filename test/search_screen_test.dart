
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

class CountingNavigatorObserver extends NavigatorObserver {
  int pushes = 0;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
    super.didPush(route, previousRoute);
  }
}

void main() {
  testWidgets('shows shimmer skeleton while loading and results after fetch', (tester) async {
    final sample = [
      Video(title: 'T1', author: 'A', username: 'u1', url: 'https://x', thumbnail: null),
    ];

    final fake = FakeApiService(result: sample, delay: const Duration(milliseconds: 150));

    await tester.pumpWidget(MaterialApp(home: SearchScreen(api: fake, autoLoad: true)));

    // FAB should be visible
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // when autoLoad is true, it will load immediately
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    // after load we should see the result
    expect(find.text('T1'), findsOneWidget);
  });

  testWidgets('tapping a result pushes a route', (tester) async {
    final sample = [
      Video(title: 'T2', author: 'A2', username: 'u2', url: 'https://x2', thumbnail: null),
    ];
    final fake = FakeApiService(result: sample, delay: Duration.zero);
    final observer = CountingNavigatorObserver();

    await tester.pumpWidget(MaterialApp(home: SearchScreen(api: fake), navigatorObservers: [observer]));

    // autoLoad is true by default, so results should load immediately
    await tester.pumpAndSettle();

    // verify result is visible
    expect(find.text('T2'), findsOneWidget);

    // tap the result to navigate
    await tester.tap(find.text('T2'));
    await tester.pumpAndSettle();

    // Verify push happened
    expect(observer.pushes, greaterThanOrEqualTo(1));
  });
}
