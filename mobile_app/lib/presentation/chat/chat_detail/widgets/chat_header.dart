import 'package:flutter/material.dart';

// Header widget for the chat detail screen
class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final String matchId;
  final String matchName;
  final String matchAvatar;
  final String? matchStatus;
  final String? matchUsername;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfileTap;
  final VoidCallback? onInfoTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onVideoCallTap;

  const ChatHeader({
    super.key,
    required this.matchId,
    required this.matchName,
    required this.matchAvatar,
    this.matchStatus,
    this.matchUsername,
    this.onBackPressed,
    this.onProfileTap,
    this.onInfoTap,
    this.onCallTap,
    this.onVideoCallTap,
  });

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
                          if (matchUsername != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '@$matchUsername',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
                // Voice call button
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: onCallTap,
                  tooltip: 'Voice Call',
                  splashRadius: 24,
                ),

                // Video call button
                IconButton(
                  icon: const Icon(Icons.videocam),
                  onPressed: onVideoCallTap,
                  tooltip: 'Video Call',
                  splashRadius: 24,
                ),

                // Info button
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: onInfoTap,
                  tooltip: 'Chat Information',
                  splashRadius: 24,
                ),
              ],
            ),
          ],
        ),
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
    super.key,
    required this.matchName,
    required this.matchAvatar,
    this.onBackPressed,
  });

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
