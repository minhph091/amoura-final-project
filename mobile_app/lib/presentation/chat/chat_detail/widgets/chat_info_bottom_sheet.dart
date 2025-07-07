import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../profile/view/profile_view.dart';

class ChatInfoBottomSheet extends StatelessWidget {
  final String userId;
  final String name;
  final String username;
  final String avatarUrl;
  final bool isNotificationsEnabled;
  final List<String> sharedPhotos;
  final Function(bool) onToggleNotifications;
  final VoidCallback onSearchMessages;
  final VoidCallback onViewAllPhotos;

  const ChatInfoBottomSheet({
    super.key,
    required this.userId,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.isNotificationsEnabled,
    required this.sharedPhotos,
    required this.onToggleNotifications,
    required this.onSearchMessages,
    required this.onViewAllPhotos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // User info section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 40,
                  backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl) as ImageProvider
                    : const AssetImage('assets/images/avatars/default_avatar.png'),
                ),
                const SizedBox(height: 16),

                // User name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Username
                Text(
                  '@$username',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Action options
          _buildActionItem(
            context,
            Icons.search,
            'Search messages',
            onSearchMessages,
          ),

          _buildActionItem(
            context,
            Icons.person_outline,
            'View Profile',
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileView(isMyProfile: false),
                ),
              );
            },
          ),

          _buildToggleItem(
            context,
            isNotificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
            isNotificationsEnabled ? 'Notifications enabled' : 'Notifications disabled',
            isNotificationsEnabled,
            (value) {
              onToggleNotifications(value);
            },
          ),

          const Divider(height: 30),

          // Photos section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Photos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (sharedPhotos.length > 4)
                      GestureDetector(
                        onTap: onViewAllPhotos,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('See all', style: TextStyle(color: AppColors.primary)),
                            Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Photos grid
                if (sharedPhotos.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('No shared photos yet'),
                    ),
                  )
                else
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: sharedPhotos.take(4).map((photoUrl) => _buildPhotoThumbnail(context, photoUrl)).toList(),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(BuildContext context, IconData icon, String text, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail(BuildContext context, String photoUrl) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(photoUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
