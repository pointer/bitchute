import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video.dart';

class ApiService {
  static const String base = 'https://api.smat-app.com/content';

  final http.Client client;
  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Video>> search(String query, {int limit = 50}) async {
    final encoded = Uri.encodeQueryComponent(query);
    final url = Uri.parse('$base?term=$encoded&limit=$limit&site=bitchute_video&esquery=false&sortdesc=false');

    final resp = await client.get(url);

    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch results: ${resp.statusCode}');
    }

    final Map<String, dynamic> jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;
    final hits = (jsonBody['hits']?['hits'] as List?) ?? [];

    return hits.map((h) => Video.fromJson(h as Map<String, dynamic>)).toList();
  }
}
