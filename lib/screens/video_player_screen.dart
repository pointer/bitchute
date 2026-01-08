import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final String title;
  const VideoPlayerScreen({Key? key, required this.url, required this.title}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  WebViewController? _controller;
  bool _webviewAvailable = true;

  @override
  void initState() {
    super.initState();
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.url));
    } catch (e) {
      // WebView platform not available (e.g., in widget tests). Fall back.
      _webviewAvailable = false;
    }
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _webviewAvailable && _controller != null
          ? WebViewWidget(controller: _controller!)
          : Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('WebView is not available in this environment.'),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _openExternal, child: const Text('Open in browser')),
              ]),
            ),
    );
  }
}
