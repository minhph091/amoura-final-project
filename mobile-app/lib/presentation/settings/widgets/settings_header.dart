import 'package:flutter/material.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with Provider/model data for avatar & name
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 38,
            // backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(displayName, style: ...)
                // Text('View & edit your profile', style: ...)
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
        ],
      ),
    );
  }
}