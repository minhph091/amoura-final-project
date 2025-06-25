// filepath: c:\amoura-final-project\mobile-app\lib\presentation\chat\conversation\widgets\message_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/chat/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMyMessage;
  final bool showTimestamp;
  final bool showAvatar;
  final String senderName;
  final String? senderAvatarUrl;
  final Function(MessageModel) onMessageLongPress;
  final Function(MessageModel) onDoubleTap;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMyMessage,
    this.showTimestamp = true,
    this.showAvatar = true,
    required this.senderName,
    this.senderAvatarUrl,
    required this.onMessageLongPress,
    required this.onDoubleTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Skip building if message is recalled and show recall notification instead
    if (message.isRecalled) {
      return _buildRecalledMessage(context);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar for received messages
          if (!isMyMessage && showAvatar) ...[
            _buildAvatar(context),
            const SizedBox(width: 8),
          ],

          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Sender name for received messages
                if (!isMyMessage && !message.isRecalled)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, bottom: 2.0),
                    child: Text(
                      senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),

                // Message bubble with content
                GestureDetector(
                  onLongPress: () => onMessageLongPress(message),
                  onDoubleTap: () => onDoubleTap(message),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: isMyMessage
                          ? theme.colorScheme.primary.withValues(alpha: 0.9)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: SelectableText(
                      message.content,
                      style: TextStyle(
                        color: isMyMessage
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),

                // Message timestamp and status indicators
                if (showTimestamp)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0, right: 4.0, left: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.isEdited)
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Text(
                              'edited',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        Text(
                          DateFormat('HH:mm').format(message.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        if (isMyMessage) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 12,
                            color: message.isRead
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Spacing after sent messages
          if (isMyMessage && showAvatar)
            const SizedBox(width: 28), // Width to balance with avatar
        ],
      ),
    ).animate().fade(duration: 200.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 200.ms);
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      ),
      child: senderAvatarUrl != null && senderAvatarUrl!.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          senderAvatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      )
          : Center(
        child: Text(
          senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRecalledMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMyMessage && showAvatar) ...[
            _buildAvatar(context),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              isMyMessage
                  ? 'You recalled a message'
                  : '$senderName recalled a message',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
          if (isMyMessage && showAvatar)
            const SizedBox(width: 28),
        ],
      ),
    ).animate().fade(duration: 200.ms);
  }
}
