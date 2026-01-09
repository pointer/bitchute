import 'package:flutter/material.dart';
import '../models/notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<BitchuteNotification> _notifications = [
    BitchuteNotification(
      id: '1',
      title: 'New video from Ickonic',
      message: 'Trending: Ep3 : Musk & Starmer, Pretend Enemies?',
      type: 'video',
      relatedId: 'video_1',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    BitchuteNotification(
      id: '2',
      title: 'Someone liked your video',
      message: '5 people liked your video',
      type: 'like',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Badge(
                  label: Text(unreadCount.toString()),
                  child: const Icon(Icons.notifications),
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return ListTile(
                  leading: Icon(
                    notification.type == 'video'
                        ? Icons.video_library
                        : notification.type == 'like'
                            ? Icons.favorite
                            : notification.type == 'comment'
                                ? Icons.comment
                                : Icons.person_add,
                    color: notification.isRead ? Colors.grey : Colors.blue,
                  ),
                  title: Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text(notification.message),
                  trailing: notification.isRead ? null : const Icon(Icons.circle, size: 8, color: Colors.blue),
                );
              },
            ),
    );
  }
}
