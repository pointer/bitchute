class Video {
  final String title;
  final String author;
  final String username;
  final String url;
  final String? thumbnail;

  Video({required this.title, required this.author, required this.username, required this.url, this.thumbnail});

  factory Video.fromJson(Map<String, dynamic> json) {
    final src = json['_source'] as Map<String, dynamic>? ?? {};
    final meta = (src['meta'] ?? {}) as Map<String, dynamic>? ?? {};

    // Try several common keys for thumbnails
    String? thumb;
    if (src['thumbnail'] != null) thumb = src['thumbnail'] as String?;
    else if (src['thumbnail_url'] != null) thumb = src['thumbnail_url'] as String?;
    else if (src['poster'] != null) thumb = src['poster'] as String?;
    else if (meta['thumbnail'] != null) thumb = meta['thumbnail'].toString();

    return Video(
      title: (src['title'] ?? '') as String,
      author: (src['channel'] ?? '') as String,
      username: (meta['channel_id'] ?? '').toString(),
      url: (src['canonical'] ?? '') as String,
      thumbnail: thumb,
    );
  }
}
