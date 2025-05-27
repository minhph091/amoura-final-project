import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});
  @override
  Widget build(BuildContext context) {
    // Avatar, display name, status etc. Use Provider/model for data.
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            // backgroundImage: NetworkImage(profile.avatarUrl), // get from model/provider
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(profile.displayName ?? '', style: ...)
                // Text(profile.status ?? '', style: ...)
              ],
            ),
          ),
        ],
      ),
    );
  }
}