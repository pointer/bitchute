import 'package:flutter_test/flutter_test.dart';
import 'package:bitchute_browser/services/api_service.dart';

void main() {
  test('ApiService.live search prints sample titles', () async {
    final api = ApiService();
    try {
      final res = await api.search('cats', limit: 10);
      if (res.isEmpty) {
        print('No results returned');
      } else {
        final titles = res.take(5).map((v) => v.title).toList();
        print('Found ${res.length} results; sample titles: ${titles.join(', ')}');
      }
      expect(true, isTrue);
    } catch (e) {
      print('ApiService.search threw: $e');
      // fail the test so we can see the error in CI/logs
      expect(e, isNull);
    }
  }, timeout: const Timeout(Duration(seconds: 30)));
}
