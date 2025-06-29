import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/message.dart';
import '../../../../core/utils/url_transformer.dart';  // Import MessageStatus and MessageType from domain model

class MessageItem extends StatelessWidget {
  final String message;
  final String senderName;
  final String? senderAvatar;
  final DateTime timestamp;
  final bool isMe;
  final MessageStatus status;
  final MessageType type;
  final String? replyToMessage;
  final String? replyToSender;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final Function()? onTapRepliedMessage;
  final String? mediaUrl;
  final String? fileInfo;

  const MessageItem({
    Key? key,
    required this.message,
    required this.senderName,
    this.senderAvatar,
    required this.timestamp,
    required this.isMe,
    this.status = MessageStatus.sent,
    this.type = MessageType.text,
    this.replyToMessage,
    this.replyToSender,
    this.onLongPress,
    this.onDoubleTap,
    this.onTapRepliedMessage,
    this.mediaUrl,
    this.fileInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for other user messages (not shown for current user)
          if (!isMe) _buildAvatar(),

          // Message bubble
          GestureDetector(
            onLongPress: onLongPress,
            onDoubleTap: onDoubleTap,
            child: Animate(
              effects: [
                SlideEffect(
                  begin: Offset(isMe ? 0.1 : -0.1, 0),
                  end: Offset.zero,
                  duration: 200.ms,
                  curve: Curves.easeOutQuad,
                ),
                FadeEffect(begin: 0.7, end: 1.0, duration: 200.ms),
              ],
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                decoration: BoxDecoration(
                  color: isMe
                      ? theme.colorScheme.primary.withValues(alpha: 0.9)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(18.0).copyWith(
                    bottomRight: isMe ? const Radius.circular(4.0) : null,
                    bottomLeft: !isMe ? const Radius.circular(4.0) : null,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5.0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reply preview, if this is a reply
                    if (replyToMessage != null)
                      _buildReplyPreview(theme),

                    // Message content based on message type
                    _buildMessageContent(theme),

                    // Timestamp and read status
                    _buildMessageFooter(theme),
                  ],
                ),
              ),
            ),
          ),

          // Space after message bubble
          const SizedBox(width: 4.0),

          // Status indicator for current user's messages
          if (isMe)
            _buildStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final transformedAvatarUrl = UrlTransformer.transformAvatarUrl(senderAvatar);
    debugPrint('MessageItem: Building avatar for ${senderName} with URL: $transformedAvatarUrl');
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: CircleAvatar(
        radius: 16.0,
        backgroundColor: Colors.grey.shade300,
        child: transformedAvatarUrl.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  transformedAvatarUrl,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('MessageItem: Error loading avatar for $senderName: $error');
                    return Text(
                      senderName.isNotEmpty ? senderName[0].toUpperCase() : "?",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      debugPrint('MessageItem: Avatar loaded successfully for $senderName');
                      return child;
                    }
                    return const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    );
                  },
                ),
              )
            : Text(
                senderName.isNotEmpty ? senderName[0].toUpperCase() : "?",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
      ),
    );
  }

  Widget _buildReplyPreview(ThemeData theme) {
    return GestureDetector(
      onTap: onTapRepliedMessage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        margin: const EdgeInsets.only(bottom: 4.0),
        decoration: BoxDecoration(
          color: isMe
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.dividerColor.withValues(alpha: 0.2),
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              replyToSender ?? "Unknown User",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
                color: isMe ? Colors.white70 : theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              replyToMessage!,
              style: TextStyle(
                fontSize: 12.0,
                color: isMe ? Colors.white70 : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(ThemeData theme) {
    switch (type) {
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.video:
        return _buildVideoMessage();
      case MessageType.audio:
        return _buildAudioMessage(theme);
      case MessageType.file:
        return _buildFileMessage(theme);
      case MessageType.emoji:
        return _buildEmojiMessage(theme);
      case MessageType.system:
        return _buildSystemMessage(theme);
      case MessageType.text:
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Text(
            message,
            style: TextStyle(
              color: isMe ? Colors.white : theme.colorScheme.onSurface,
              fontSize: 16.0,
            ),
          ),
        );
    }
  }

  Widget _buildImageMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16.0),
          ),
          child: Image.network(
            mediaUrl ?? 'https://via.placeholder.com/300',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 150,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported, size: 50),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: double.infinity,
                height: 150,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
        if (message.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoMessage() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16.0),
              ),
              child: Image.network(
                mediaUrl ?? 'https://via.placeholder.com/300',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
        if (message.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAudioMessage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isMe ? Colors.white24 : theme.dividerColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.play_arrow,
              color: isMe ? Colors.white : theme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: isMe ? Colors.white38 : theme.dividerColor,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message.isNotEmpty ? message : "Voice message",
                  style: TextStyle(
                    fontSize: 14,
                    color: isMe ? Colors.white70 : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileMessage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isMe ? Colors.white24 : theme.dividerColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.description,
              color: isMe ? Colors.white : theme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.isNotEmpty ? message : "File",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fileInfo != null)
                  Text(
                    fileInfo!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isMe ? Colors.white70 : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiMessage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Text(
        message,
        style: TextStyle(
          color: isMe ? Colors.white : theme.colorScheme.onSurface,
          fontSize: 32.0, // Emoji thường lớn hơn text thường
        ),
      ),
    );
  }

  Widget _buildSystemMessage(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 12.0,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMessageFooter(ThemeData theme) {
    final timeFormat = DateFormat('HH:mm');
    final formattedTime = timeFormat.format(timestamp);

    return Padding(
      padding: const EdgeInsets.only(right: 12.0, bottom: 6.0, left: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 11.0,
              color: isMe ? Colors.white70 : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Widget statusIcon;

    switch (status) {
      case MessageStatus.sending:
        statusIcon = const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        );
        break;
      case MessageStatus.sent:
        statusIcon = const Icon(
          Icons.check,
          size: 14,
          color: Colors.grey,
        );
        break;
      case MessageStatus.delivered:
        statusIcon = const Icon(
          Icons.done_all,
          size: 14,
          color: Colors.grey,
        );
        break;
      case MessageStatus.read:
        statusIcon = const Icon(
          Icons.done_all,
          size: 14,
          color: Colors.blue,
        );
        break;
      case MessageStatus.failed:
        statusIcon = const Icon(
          Icons.error_outline,
          size: 14,
          color: Colors.red,
        );
        break;
    }

    return statusIcon;
  }
}
