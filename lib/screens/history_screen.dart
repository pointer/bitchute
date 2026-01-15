import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/history_service.dart';
import '../widgets/video_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryService>().history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu item selection
              switch (value) {
                case 'account':
                  // TODO: Navigate to account settings
                  break;
                case 'privacy':
                  // TODO: Navigate to privacy settings
                  break;
                case 'notifications':
                  // TODO: Navigate to notification settings
                  break;
                case 'help':
                  // TODO: Navigate to help
                  break;
                case 'about':
                  // TODO: Show about dialog
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'account',
                child: Row(
                  children: [
                    Icon(Icons.account_circle),
                    SizedBox(width: 8),
                    Text('Account'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'privacy',
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip),
                    SizedBox(width: 8),
                    Text('Privacy'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'notifications',
                child: Row(
                  children: [
                    Icon(Icons.notifications),
                    SizedBox(width: 8),
                    Text('Notifications'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help),
                    SizedBox(width: 8),
                    Text('Help & Support'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('About'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.settings),
          ),
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => context.read<HistoryService>().clear(),
            ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('No viewing history'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => VideoTile(video: history[index]),
            ),
    );
  }
}
