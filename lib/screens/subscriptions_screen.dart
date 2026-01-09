import 'package:flutter/material.dart';
import '../models/subscription.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  // Mock subscription list
  final List<Subscription> _subscriptions = [
    Subscription(
      channelId: 'ch1',
      channelName: 'Ickonic',
      subscriberCount: 1153,
      subscribedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Subscription(
      channelId: 'ch2',
      channelName: 'Tech News Daily',
      subscriberCount: 45000,
      subscribedAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _subscriptions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.subscriptions, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No subscriptions yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Subscribe to channels to see their latest videos', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _subscriptions.length,
              itemBuilder: (context, index) {
                final sub = _subscriptions[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(sub.channelName[0]),
                  ),
                  title: Text(sub.channelName),
                  subtitle: Text('${sub.subscriberCount} subscribers'),
                  trailing: const Icon(Icons.check_circle, color: Colors.blue),
                );
              },
            ),
    );
  }
}
