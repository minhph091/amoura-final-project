import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../domain/models/chat.dart';
import '../../chat_detail/chat_detail_view.dart';

class ChatItem extends StatelessWidget {
  final Chat chat;
  final String currentUserId;
  final Function(String)? onChatSelected;
  final bool isSelected;

  const ChatItem({
    Key? key,
    required this.chat,
    required this.currentUserId,
    this.onChatSelected,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine recipient info (for 1:1 chats)
    final bool isSelfChat = chat.participantIds.length == 1 &&
                           chat.participantIds.contains(currentUserId);
    String displayName;
    String? avatarUrl;
    bool isOnline = false;

    if (chat.isGroup) {
      // Group chat
      displayName = chat.groupName ?? "Group";
      avatarUrl = chat.groupAvatar;
    } else if (isSelfChat) {
      // Notes to self
      displayName = "Notes to Self";
      avatarUrl = null; // Maybe use app icon or user's own avatar
    } else {
      // 1:1 chat - find the other participant
      displayName = "Chat Contact"; // This would come from user repository normally
      avatarUrl = null; // This would come from user repository normally
      isOnline = false; // This would come from user presence service normally
    }

    return InkWell(
      onTap: () {
        if (onChatSelected != null) {
          onChatSelected!(chat.id);
        } else {
          // Navigate to chat detail page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailView(
                chatId: chat.id,
                recipientName: displayName,
                recipientAvatar: avatarUrl,
                isOnline: isOnline,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withAlpha(50)
              : theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withAlpha(50),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar with online indicator
            _buildAvatar(displayName, avatarUrl, isOnline),
            const SizedBox(width: 12.0),

            // Chat info (name, last message, time)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chat name and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Chat name
                      Expanded(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontWeight: chat.muted ? FontWeight.normal : FontWeight.bold,
                            fontSize: 16.0,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Last message time
                      Text(
                        _formatLastMessageTime(chat.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12.0,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4.0),

                  // Last message and unread count
                  Row(
                    children: [
                      // Last message
                      Expanded(
                        child: Text(
                          chat.lastMessage?.content ?? "No messages yet",
                          style: TextStyle(
                            fontSize: 14.0,
                            color: theme.textTheme.bodyMedium?.color?.withAlpha(200),
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Unread message count
                      if (_hasUnreadMessages(chat))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            _getUnreadCount(chat).toString(),
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // Muted indicator
                      if (chat.muted)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.volume_off,
                            size: 16.0,
                            color: theme.textTheme.bodySmall?.color,
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

  Widget _buildAvatar(String name, String? avatarUrl, bool isOnline) {
    return Stack(
      children: [
        // Avatar
        CircleAvatar(
          radius: 24.0,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: avatarUrl != null
              ? CachedNetworkImageProvider(avatarUrl) as ImageProvider
              : null,
          child: avatarUrl == null
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                )
              : null,
        ),

        // Online indicator
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12.0,
              height: 12.0,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
            ),
          ),

        // Pin indicator for pinned chats
        if (chat.pinned)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 14.0,
              height: 14.0,
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.push_pin,
                size: 8.0,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  String _formatLastMessageTime(DateTime? time) {
    if (time == null) {
      return '';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      // Today: show time
      return DateFormat('HH:mm').format(time);
    } else if (messageDate == yesterday) {
      // Yesterday: show "Yesterday"
      return 'Yesterday';
    } else if (now.difference(time).inDays < 7) {
      // Within a week: show day name
      return DateFormat('EEEE').format(time);
    } else {
      // Older: show date
      return DateFormat('dd/MM/yyyy').format(time);
    }
  }

  bool _hasUnreadMessages(Chat chat) {
    // This would connect to your unread messages tracking system
    // For now, we'll just simulate some chats having unread messages
    return chat.id.hashCode % 3 == 0;
  }

  int _getUnreadCount(Chat chat) {
    // This would also connect to your unread messages tracking system
    // For now, just return a simulated count
    return (chat.id.hashCode % 5) + 1;
  }
}
