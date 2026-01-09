class BitchuteNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'video', 'comment', 'like', 'subscription'
  final String? relatedId; // video id, comment id, etc.
  final bool isRead;
  final DateTime createdAt;

  BitchuteNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    this.isRead = false,
    required this.createdAt,
  });

  factory BitchuteNotification.fromJson(Map<String, dynamic> json) {
    return BitchuteNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'video',
      relatedId: json['relatedId'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'relatedId': relatedId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
