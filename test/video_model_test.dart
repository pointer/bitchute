import 'package:flutter_test/flutter_test.dart';
import 'package:bitchute_app/models/video.dart';

void main() {
  test('parses thumbnail from various fields', () {
    final json1 = {'_source': {'title': 't', 'channel': 'a', 'canonical': 'u', 'thumbnail': 'thumb1', 'meta': {'channel_id': 'u1'}}};
    final v1 = Video.fromJson(json1);
    expect(v1.thumbnail, 'thumb1');

    final json2 = {'_source': {'title': 't', 'channel': 'a', 'canonical': 'u', 'thumbnail_url': 'thumb2', 'meta': {'channel_id': 'u1'}}};
    final v2 = Video.fromJson(json2);
    expect(v2.thumbnail, 'thumb2');

    final json3 = {'_source': {'title': 't', 'channel': 'a', 'canonical': 'u', 'meta': {'channel_id': 'u1', 'thumbnail': 'thumb3'}}};
    final v3 = Video.fromJson(json3);
    expect(v3.thumbnail, 'thumb3');
  });
}
