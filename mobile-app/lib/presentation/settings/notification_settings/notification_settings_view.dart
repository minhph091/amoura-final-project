import 'package:flutter/material.dart';
import 'widgets/notification_switch.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Notification types from model/viewmodel/provider
    final List<String> notificationIds = [
      'newMatches',
      'newMessages',
      'profileViews',
      'boostReminder',
      'specialEvents',
      'appUpdates',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView.separated(
        itemCount: notificationIds.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return NotificationSwitch(id: notificationIds[index]);
        },
      ),
    );
  }
}