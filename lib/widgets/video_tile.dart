import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../models/video.dart';
import '../screens/video_player_screen.dart';
import '../services/history_service.dart';

class VideoTile extends StatelessWidget {
  final Video video;
  const VideoTile({Key? key, required this.video}) : super(key: key);

  Widget _thumbnail() {
    if (video.thumbnail == null || video.thumbnail!.isEmpty) {
      return const SizedBox(width: 72, height: 72, child: Icon(Icons.play_circle_fill, size: 48));
    }
    return SizedBox(
      width: 72,
      height: 72,
      child: CachedNetworkImage(
        imageUrl: video.thumbnail!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(color: Colors.grey.shade300),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: _thumbnail()),
      title: Text(video.title),
      subtitle: Text('${video.author} • ${video.username}'),
      trailing: const Icon(Icons.open_in_new),
      onTap: () {
        // Record in viewing history
        try {
          // HistoryService is provided at the app root; use read to avoid listening here
          final history = context.read<HistoryService>();
          history.add(video);
        } catch (_) {
          // ignore if provider not available in some test contexts
        }

        Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(url: video.url, title: video.title)));
      },
    );
  }
}
