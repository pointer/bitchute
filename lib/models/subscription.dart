class Subscription {
  final String channelId;
  final String channelName;
  final String? channelAvatarUrl;
  final int subscriberCount;
  final DateTime subscribedAt;

  Subscription({
    required this.channelId,
    required this.channelName,
    this.channelAvatarUrl,
    this.subscriberCount = 0,
    required this.subscribedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      channelId: json['channelId'] ?? '',
      channelName: json['channelName'] ?? '',
      channelAvatarUrl: json['channelAvatarUrl'],
      subscriberCount: json['subscriberCount'] ?? 0,
      subscribedAt: DateTime.tryParse(json['subscribedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channelId': channelId,
      'channelName': channelName,
      'channelAvatarUrl': channelAvatarUrl,
      'subscriberCount': subscriberCount,
      'subscribedAt': subscribedAt.toIso8601String(),
    };
  }
}
