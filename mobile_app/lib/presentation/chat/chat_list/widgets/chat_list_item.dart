import 'package:flutter/material.dart';
import '../chat_list_viewmodel.dart';
import '../../../shared/utils/time_formatter.dart';
import '../../../../core/utils/url_transformer.dart';

class ChatListItem extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:
            chat.isPinned
                ? (isDark
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.05))
                : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Modern Avatar with enhanced online indicator
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            chat.isOnline
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundImage:
                          chat.avatar.isNotEmpty
                              ? NetworkImage(
                                UrlTransformer.transformAvatarUrl(chat.avatar),
                              )
                              : null,
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[200],
                      child:
                          chat.avatar.isEmpty
                              ? Text(
                                chat.name.isNotEmpty
                                    ? chat.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black54,
                                ),
                              )
                              : null,
                    ),
                  ),
                  if (chat.isOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? Colors.black : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Enhanced Chat info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and time with better spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chat.name,
                            style: TextStyle(
                              fontWeight:
                                  chat.isUnread
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                              fontSize: 17,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Modern time display
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                chat.isUnread
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            TimeFormatter.formatChatTime(chat.lastMessageTime),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  chat.isUnread
                                      ? Theme.of(context).colorScheme.primary
                                      : (isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                              fontWeight:
                                  chat.isUnread
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Last message with modern styling
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.lastMessage.isEmpty
                                ? 'No messages yet'
                                : chat.lastMessage,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  chat.isUnread
                                      ? (isDark
                                          ? Colors.white70
                                          : Colors.black54)
                                      : (isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                              fontWeight:
                                  chat.isUnread
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Modern badges and indicators
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Unread count with modern badge
                            if (chat.unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  chat.unreadCount > 9
                                      ? '9+'
                                      : '${chat.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                            // Pin icon with modern style
                            if (chat.isPinned)
                              Container(
                                margin: EdgeInsets.only(
                                  left: chat.unreadCount > 0 ? 6 : 0,
                                ),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: (isDark
                                          ? Colors.orange[300]
                                          : Colors.orange[400])!
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.push_pin,
                                  size: 14,
                                  color:
                                      isDark
                                          ? Colors.orange[300]
                                          : Colors.orange[600],
                                ),
                              ),

                            // Mute icon with modern style
                            if (chat.isMuted)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: (isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600])!
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.volume_off,
                                  size: 14,
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
