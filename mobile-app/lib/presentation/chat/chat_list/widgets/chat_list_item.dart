import 'package:flutter/material.dart';
import '../chat_list_viewmodel.dart';
import '../../../shared/utils/time_formatter.dart';
import '../../../../core/utils/url_transformer.dart';

class ChatListItem extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ChatListItem({
    Key? key,
    required this.chat,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: chat.isPinned
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
              : null,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: chat.avatar.isNotEmpty
                      ? NetworkImage(UrlTransformer.transformAvatarUrl(chat.avatar))
                      : null,
                  child: chat.avatar.isEmpty
                      ? Text(
                          chat.name.isNotEmpty 
                              ? chat.name[0].toUpperCase() 
                              : '?',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name
                      Expanded(
                        child: Text(
                          chat.name,
                          style: TextStyle(
                            fontWeight: chat.isUnread ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Time
                      Text(
                        TimeFormatter.formatChatTime(chat.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: chat.isUnread
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[600],
                          fontWeight: chat.isUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Last message and unread count
                  Row(
                    children: [
                      // Last message
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: chat.isUnread
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Colors.grey[600],
                            fontWeight: chat.isUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Unread count
                      if (chat.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat.unreadCount > 9 ? '9+' : '${chat.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // Pin icon
                      if (chat.isPinned && !chat.isUnread)
                        Icon(
                          Icons.push_pin,
                          size: 16,
                          color: Colors.grey[600],
                        ),

                      // Mute icon
                      if (chat.isMuted)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.volume_off,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
