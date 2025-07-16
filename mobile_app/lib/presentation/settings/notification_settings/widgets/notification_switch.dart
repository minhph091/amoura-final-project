import 'package:flutter/material.dart';

class NotificationSwitch extends StatelessWidget {
  final String id;
  const NotificationSwitch({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    // Use Provider/ViewModel to get/set state for each notification id
    return SwitchListTile(
      title: Text(''), // Title from model/viewmodel
      subtitle: Text(''), // Subtitle from model/viewmodel
      value: false, // Should get value from viewmodel/provider
      onChanged: (val) {
        // Call viewmodel/provider method to update notification state
      },
    );
  }
}
