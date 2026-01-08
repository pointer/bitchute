import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bitchute_browser/services/api_service.dart';

void main() {
  group('ApiService', () {
    test('parses valid response into Video list', () async {
      final sample = {
        'hits': {
          'hits': [
            {
              '_source': {
                'title': 'Test Video',
                'channel': 'Test Channel',
                'meta': {'channel_id': 'testuser'},
                'canonical': 'https://www.bitchute.com/video/test/'
              }
            },
            {
              '_source': {
                'title': 'Another Video',
                'channel': 'Channel 2',
                'meta': {'channel_id': 'user2'},
                'canonical': 'https://www.bitchute.com/video/2/'
              }
            }
          ]
        }
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(sample), 200);
      });

      final api = ApiService(client: mockClient);
      final results = await api.search('test');

      expect(results.length, 2);
      expect(results[0].title, 'Test Video');
      expect(results[0].author, 'Test Channel');
      expect(results[0].username, 'testuser');
      expect(results[0].url, 'https://www.bitchute.com/video/test/');
    });

    test('throws when non-200 returned', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      final api = ApiService(client: mockClient);

      expect(api.search('x'), throwsA(isA<Exception>()));
    });
  });
}
