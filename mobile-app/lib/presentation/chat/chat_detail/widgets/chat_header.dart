import 'package:flutter/material.dart';
import 'call_button.dart';

/// Header widget for the chat detail screen
class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final String matchId;
  final String matchName;
  final String matchAvatar;
  final String? matchStatus;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfileTap;

  const ChatHeader({
    Key? key,
    required this.matchId,
    required this.matchName,
    required this.matchAvatar,
    this.matchStatus,
    this.onBackPressed,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            ),

            // User avatar and info - takes up most of the space
            Expanded(
              child: InkWell(
                onTap: onProfileTap,
                child: Row(
                  children: [
                    // User avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: matchAvatar.isNotEmpty
                          ? NetworkImage(matchAvatar) as ImageProvider
                          : const AssetImage('assets/images/avatars/default_avatar.png'),
                    ),

                    const SizedBox(width: 12),

                    // User name and status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            matchName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (matchStatus != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              matchStatus!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).hintColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Call options
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Video call button
                CallButton(
                  matchId: matchId,
                  matchName: matchName,
                  matchAvatar: matchAvatar,
                  isVideoCall: true,
                  size: 40,
                  backgroundColor: Colors.transparent,
                  iconColor: Theme.of(context).iconTheme.color,
                ),

                // Audio call button
                CallButton(
                  matchId: matchId,
                  matchName: matchName,
                  matchAvatar: matchAvatar,
                  isVideoCall: false,
                  size: 40,
                  backgroundColor: Colors.transparent,
                  iconColor: Theme.of(context).iconTheme.color,
                ),

                // More options menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    // Handle menu item selection
                    _handleMenuItemSelected(context, value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 8),
                          Text('View Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'block',
                      child: Row(
                        children: [
                          Icon(Icons.block),
                          SizedBox(width: 8),
                          Text('Block User'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag),
                          SizedBox(width: 8),
                          Text('Report'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'unmatch',
                      child: Row(
                        children: [
                          Icon(Icons.close),
                          SizedBox(width: 8),
                          Text('Unmatch'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuItemSelected(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        if (onProfileTap != null) {
          onProfileTap!();
        }
        break;
      case 'block':
        _showConfirmationDialog(
          context,
          'Block User',
          'Are you sure you want to block this user? You will no longer receive messages from them.',
          'Block',
          () {
            // TODO: Implement block functionality
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(); // Go back to chat list
          },
        );
        break;
      case 'report':
        // Navigate to report screen
        // TODO: Implement report functionality
        break;
      case 'unmatch':
        _showConfirmationDialog(
          context,
          'Unmatch',
          'Are you sure you want to unmatch with this user? This action cannot be undone.',
          'Unmatch',
          () {
            // TODO: Implement unmatch functionality
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(); // Go back to chat list
          },
        );
        break;
    }
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    String confirmText,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// A simpler version of the chat header with fewer options
class SimpleChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final String matchName;
  final String matchAvatar;
  final VoidCallback? onBackPressed;

  const SimpleChatHeader({
    Key? key,
    required this.matchName,
    required this.matchAvatar,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: matchAvatar.isNotEmpty
                ? NetworkImage(matchAvatar) as ImageProvider
                : const AssetImage('assets/images/avatars/default_avatar.png'),
          ),
          const SizedBox(width: 8),
          Text(
            matchName,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
      elevation: 1,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
