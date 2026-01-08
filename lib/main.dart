import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'models/video.dart';
import 'services/api_service.dart';
import 'widgets/video_tile.dart';

void main() => runApp(const BitchuteApp());

class BitchuteApp extends StatelessWidget {
  const BitchuteApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(title: 'Bitchute', home: SearchScreen());
}

class SearchScreen extends StatefulWidget {
  final ApiService api;
  SearchScreen({Key? key, ApiService? api}) : api = api ?? ApiService(), super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  late final ApiService _api;
  List<Video> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = widget.api;
  }

  void _doSearch() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });
    try {
      final res = await _api.search(q);
      setState(() {
        _results = res;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Bitchute Browser')),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(children: [
              Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Search...'))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _loading ? null : _doSearch, child: const Text('Search'))
            ]),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('Error: $_error', style: const TextStyle(color: Colors.red))),
            Expanded(
                child: _loading
                    ? ListView.separated(
                        itemCount: 6,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(children: [
                            ClipRRect(borderRadius: BorderRadius.circular(8), child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(width: 72, height: 72, color: Colors.grey.shade300),
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Shimmer.fromColors(baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100, child: Container(width: double.infinity, height: 14, color: Colors.grey.shade300)),
                              const SizedBox(height: 8),
                              Shimmer.fromColors(baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100, child: Container(width: 120, height: 12, color: Colors.grey.shade300)),
                            ])),
                          ]),
                        ),
                      )
                    : _results.isEmpty
                        ? const Center(child: Text('No results'))
                        : ListView.builder(itemCount: _results.length, itemBuilder: (context, i) => VideoTile(video: _results[i]))),
          ]),
        ),
      );}