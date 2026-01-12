import 'package:flutter/foundation.dart';
import '../models/video.dart';

class HistoryService extends ChangeNotifier {
  final List<Video> _history = [];

  List<Video> get history => List.unmodifiable(_history);

  void add(Video video) {
    // Keep most recent first and avoid duplicates
    _history.removeWhere((v) => v.url == video.url);
    _history.insert(0, video);
    // Keep history bounded
    if (_history.length > 200) _history.removeLast();
    notifyListeners();
  }

  void clear() {
    _history.clear();
    notifyListeners();
  }
}
