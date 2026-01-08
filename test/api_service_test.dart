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

      await expectLater(api.search('x'), throwsA(isA<Exception>()));
    });

    test('retries on transient 5xx and eventually succeeds', () async {
      int calls = 0;
      final sample = {
        'hits': {
          'hits': [
            {
              '_source': {
                'title': 'Retry Success',
                'channel': 'Retry Channel',
                'meta': {'channel_id': 'retryuser'},
                'canonical': 'https://www.bitchute.com/video/retry/'
              }
            }
          ]
        }
      };
      final mockClient = MockClient((request) async {
        calls++;
        if (calls < 3) return http.Response('Server error', 500);
        return http.Response(jsonEncode(sample), 200);
      });

      final api = ApiService(client: mockClient);
      final res = await api.search('x');
      expect(res.length, 1);
      expect(calls, 3);
    });

    test('honors configured maxAttempts', () async {
      int calls = 0;
      final mockClient = MockClient((request) async {
        calls++;
        return http.Response('Server error', 500);
      });
      final api = ApiService(client: mockClient, maxAttempts: 2, baseDelayMs: 1);
      await expectLater(api.search('x'), throwsA(isA<Exception>()));
      expect(calls, 2);
    });

    test('does not retry on 4xx', () async {
      int calls = 0;
      final mockClient = MockClient((request) async {
        calls++;
        return http.Response('Not found', 404);
      });
      final api = ApiService(client: mockClient);
      await expectLater(api.search('x'), throwsA(isA<Exception>()));
      expect(calls, 1);
    });

    test('retries on exception then succeeds', () async {
      int calls = 0;
      final sample = {
        'hits': {
          'hits': [
            {
              '_source': {
                'title': 'Exception Retry',
                'channel': 'E Channel',
                'meta': {'channel_id': 'euser'},
                'canonical': 'https://www.bitchute.com/video/exception/'
              }
            }
          ]
        }
      };
      final mockClient = MockClient((request) async {
        calls++;
        if (calls == 1) throw Exception('Network error');
        return http.Response(jsonEncode(sample), 200);
      });
      final api = ApiService(client: mockClient);
      final res = await api.search('x');
      expect(res.length, 1);
      expect(calls, 2);
    });
    test('uses thumbnail_url when thumbnail missing', () async {
      final sample = {
        'hits': {
          'hits': [
            { '_source': {'title':'t','channel':'a','meta':{'channel_id':'u'}, 'canonical':'u','thumbnail_url':'tn.png'} }
          ]
        }
      };
      final mock = MockClient((r) async => http.Response(jsonEncode(sample), 200));
      final api = ApiService(client: mock);
      final res = await api.search('x');
      expect(res[0].thumbnail, 'tn.png');
    });
  });
}
