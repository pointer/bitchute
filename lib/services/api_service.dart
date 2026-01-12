import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video.dart';
import '../models/notification.dart';

class ApiService {
  static const String base = 'https://api.smat-app.com/content';

  final http.Client client;
  final int maxAttempts;
  final int baseDelayMs;
  final Duration timeout;

  ApiService({http.Client? client, int maxAttempts = 3, int baseDelayMs = 10, Duration timeout = const Duration(seconds: 10)})
      : client = client ?? http.Client(),
        maxAttempts = maxAttempts,
        baseDelayMs = baseDelayMs,
        timeout = timeout;

  Future<List<Video>> search(String query, {int limit = 50}) async {
    final url = Uri.parse(base).replace(queryParameters: {
      'term': query,
      'limit': '$limit',
      'site': 'bitchute_video',
      'esquery': 'false',
      'sortdesc': 'false',
    });


    int attempt = 0;

    while (true) {
      attempt++;
      http.Response resp;

      try {
        // Add a timeout to avoid hanging indefinitely
        resp = await client.get(url).timeout(timeout, onTimeout: () {
          throw Exception('Request timed out');
        });
      } catch (e) {
        // Retry on network errors / timeouts
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(milliseconds: baseDelayMs * (1 << (attempt - 1))));
          continue;
        }
        throw Exception('Failed to fetch results after $attempt attempts: $e');
      }

      if (resp.statusCode == 200) {
        // Safer JSON parsing with correct encoding handling. Use the raw
        // response bytes and decode as UTF-8 before JSON parsing to avoid
        // mojibake when the server returns UTF-8 content.
        final dynamic decoded;
        try {
          decoded = jsonDecode(utf8.decode(resp.bodyBytes));
        } catch (e) {
          throw Exception('Failed to parse response JSON: $e');
        }

        if (decoded is! Map<String, dynamic>) {
          throw Exception('Unexpected response shape: expected object at top-level');
        }

        final hitsList = ((decoded['hits'] is Map) ? (decoded['hits'] as Map)['hits'] : null) as List? ?? [];

        final results = <Video>[];
        for (final h in hitsList) {
          if (h is Map<String, dynamic>) {
            results.add(Video.fromJson(h));
          }
        }

        return results;
      } else if (resp.statusCode >= 500 && resp.statusCode < 600) {
        // Server error — retry if attempts remain
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(milliseconds: baseDelayMs * (1 << (attempt - 1))));
          continue;
        }
        throw Exception('Failed to fetch results: ${resp.statusCode}');
      } else {
        // Client error or other non-retryable status
        throw Exception('Failed to fetch results: ${resp.statusCode}');
      }
    }
  }

  /// Fetch notifications list. Returns empty list on error.
  Future<List<BitchuteNotification>> notifications() async {
    final url = Uri.parse('https://api.smat-app.com/notifications');
    try {
      final resp = await client.get(url).timeout(timeout);
      if (resp.statusCode == 200) {
        final dynamic decoded = jsonDecode(utf8.decode(resp.bodyBytes));
        final items = <BitchuteNotification>[];
        if (decoded is List) {
          for (final e in decoded) {
            if (e is Map<String, dynamic>) items.add(BitchuteNotification.fromJson(e));
          }
        } else if (decoded is Map && decoded['notifications'] is List) {
          for (final e in (decoded['notifications'] as List)) {
            if (e is Map<String, dynamic>) items.add(BitchuteNotification.fromJson(e));
          }
        }
        return items;
      }
    } catch (e) {
      // ignore and return empty list
    }
    return [];
  }

  /// Convenience helper to load a "home" or trending feed. It currently maps
  /// to a search for a fixed query but exists so consumers can request the
  /// home feed explicitly without needing to know the query.
  Future<List<Video>> homeFeed({int limit = 50}) => search('trending', limit: limit);
}

