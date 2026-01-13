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

  Widget _thumbnail(BuildContext context) {
    if (video.thumbnail == null || video.thumbnail!.isEmpty) {
      return SizedBox(width: 72, height: 72, child: Icon(Icons.play_circle_fill, size: 48, color: Theme.of(context).iconTheme.color));
    }
    return SizedBox(
      width: 72,
      height: 72,
      child: CachedNetworkImage(
        imageUrl: video.thumbnail!,
        fit: BoxFit.cover,
        placeholder: (context, url) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Shimmer.fromColors(
            baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
            child: Container(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          );
        },
        errorWidget: (context, url, error) => Icon(Icons.broken_image, color: Theme.of(context).iconTheme.color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: _thumbnail(context)),
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
