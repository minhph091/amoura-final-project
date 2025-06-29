import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/message.dart';
import '../../../../core/utils/url_transformer.dart';
import 'audio_message_item.dart';
import 'video_message_item.dart';
import 'full_screen_image_viewer.dart';

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
  final VoidCallback? onSwipeReply;
  final String? mediaUrl;
  final String? fileInfo;
  final bool recalled;

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
    this.onSwipeReply,
    this.mediaUrl,
    this.fileInfo,
    this.recalled = false,
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

          // Message bubble with swipe-to-reply
          _buildSwipeableMessage(maxWidth, theme),

          // Space after message bubble
          const SizedBox(width: 4.0),

          // Status indicator for current user's messages
          if (isMe)
            _buildStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildSwipeableMessage(double maxWidth, ThemeData theme) {
    return GestureDetector(
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      onHorizontalDragEnd: (details) {
        // Swipe to reply functionality
        if (onSwipeReply != null) {
          // Detect swipe direction and distance
          final velocity = details.velocity.pixelsPerSecond.dx;
          final primaryVelocity = details.primaryVelocity ?? 0;
          
          // For other user's messages: swipe right to reply
          // For own messages: swipe left to reply
          if ((!isMe && primaryVelocity > 500) || (isMe && primaryVelocity < -500)) {
            debugPrint('MessageItem: Swipe to reply detected - isMe: $isMe, velocity: $primaryVelocity');
            onSwipeReply!();
          }
        }
      },
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
            gradient: isMe
                ? const LinearGradient(
                    colors: [Color(0xFFFF6B9D), Color(0xFFFF8E9E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(20.0).copyWith(
              bottomRight: isMe ? const Radius.circular(6.0) : null,
              bottomLeft: !isMe ? const Radius.circular(6.0) : null,
            ),
            boxShadow: [
              BoxShadow(
                color: isMe 
                    ? Colors.pink.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 8.0,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
            border: !isMe ? Border.all(
              color: Colors.grey.shade200,
              width: 1.0,
            ) : null,
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
    );
  }

  Widget _buildAvatar() {
    final transformedAvatarUrl = UrlTransformer.transformAvatarUrl(senderAvatar);
    debugPrint('MessageItem: Building avatar for ${senderName} with URL: $transformedAvatarUrl');
    
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B9D), Color(0xFFFF8E9E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
              blurRadius: 8.0,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 18.0,
          backgroundColor: Colors.transparent,
          child: transformedAvatarUrl.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      transformedAvatarUrl,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('MessageItem: Error loading avatar for $senderName: $error');
                        return Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF6B9D), Color(0xFFFF8E9E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              senderName.isNotEmpty ? senderName[0].toUpperCase() : "?",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          debugPrint('MessageItem: Avatar loaded successfully for $senderName');
                          return child;
                        }
                        return Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    senderName.isNotEmpty ? senderName[0].toUpperCase() : "?",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildReplyPreview(ThemeData theme) {
    return GestureDetector(
      onTap: onTapRepliedMessage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        margin: const EdgeInsets.only(bottom: 6.0),
        decoration: BoxDecoration(
          gradient: isMe
              ? LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.shade100,
                    Colors.grey.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: const BorderRadius.all(Radius.circular(14.0)),
          border: Border.all(
            color: isMe 
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.grey.shade300.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 3.0,
              height: 30.0,
              decoration: BoxDecoration(
                color: isMe 
                    ? Colors.white.withValues(alpha: 0.8)
                    : const Color(0xFFFF6B9D),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    replyToSender ?? "Unknown User",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11.0,
                      color: isMe 
                          ? Colors.white.withValues(alpha: 0.9)
                          : const Color(0xFFFF6B9D),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    replyToMessage!,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: isMe 
                          ? Colors.white.withValues(alpha: 0.75)
                          : Colors.grey.shade600,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(ThemeData theme) {
    // Check if message is recalled
    if (recalled) {
      return _buildRecalledMessage(theme);
    }
    
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
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Text(
            message,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.grey.shade800,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
              height: 1.4,
              letterSpacing: 0.2,
            ),
          ),
        );
    }
  }

  Widget _buildImageMessage() {
    // Transform URL for Android emulator compatibility
    final transformedImageUrl = UrlTransformer.transformImageUrl(mediaUrl ?? '');
    debugPrint('MessageItem: Building image message with URL: $mediaUrl -> $transformedImageUrl');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              if (transformedImageUrl.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageViewer(
                      imageUrl: mediaUrl!,
                      caption: (message.isNotEmpty && message != 'Photo') ? message : null,
                    ),
                    fullscreenDialog: true,
                  ),
                );
              }
            },
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16.0),
            ),
            child: transformedImageUrl.isNotEmpty
                ? Image.network(
                    transformedImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('MessageItem: Error loading image: $error');
                      debugPrint('MessageItem: Image URL: $transformedImageUrl');
                      return Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey.shade300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                            const SizedBox(height: 8),
                            const Text('Failed to load image', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        debugPrint('MessageItem: Image loaded successfully');
                        return child;
                      }
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
                  )
                : Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.grey.shade300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image, size: 50, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('No image URL', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
            ),
          ),
        ),
        if (message.isNotEmpty && message != 'Photo')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              gradient: isMe
                  ? const LinearGradient(
                      colors: [Color(0xFFFF6B9D), Color(0xFFFF8E9E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.white, Colors.grey.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16.0),
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.grey.shade800,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ),
      ],
    );
  }



  Widget _buildVideoMessage() {
    // Extract file size and duration from message content or fileInfo
    String? fileSize;
    Duration? duration;
    
    // Parse fileInfo if available (format: "filename.mp4 • 5.2 MB • 2:30")
    if (fileInfo != null) {
      final parts = fileInfo!.split(' • ');
      if (parts.length >= 2) {
        fileSize = parts[1]; // Extract size
      }
      if (parts.length >= 3) {
        // Parse duration from format "2:30" or "1:23:45"
        final timeParts = parts[2].split(':');
        if (timeParts.length == 2) {
          final minutes = int.tryParse(timeParts[0]) ?? 0;
          final seconds = int.tryParse(timeParts[1]) ?? 0;
          duration = Duration(minutes: minutes, seconds: seconds);
        } else if (timeParts.length == 3) {
          final hours = int.tryParse(timeParts[0]) ?? 0;
          final minutes = int.tryParse(timeParts[1]) ?? 0;
          final seconds = int.tryParse(timeParts[2]) ?? 0;
          duration = Duration(hours: hours, minutes: minutes, seconds: seconds);
        }
      }
    }

    return VideoMessageItem(
      videoUrl: mediaUrl ?? '',
      thumbnailUrl: mediaUrl, // Use same URL for thumbnail for now
      duration: duration,
      fileSize: fileSize,
      isMe: isMe,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
    );
  }

  Widget _buildAudioMessage(ThemeData theme) {
    // Extract duration from fileInfo if available (format: "voice_note.m4a • 3.2 MB • 1:45")
    Duration? duration;
    
    if (fileInfo != null) {
      final parts = fileInfo!.split(' • ');
      if (parts.length >= 3) {
        // Parse duration from format "1:45"
        final timeParts = parts[2].split(':');
        if (timeParts.length == 2) {
          final minutes = int.tryParse(timeParts[0]) ?? 0;
          final seconds = int.tryParse(timeParts[1]) ?? 0;
          duration = Duration(minutes: minutes, seconds: seconds);
        }
      }
    }
    
    // Fallback: parse duration from message content if it looks like time format
    if (duration == null && message.contains(':')) {
      final timeParts = message.split(':');
      if (timeParts.length == 2) {
        final minutes = int.tryParse(timeParts[0]) ?? 0;
        final seconds = int.tryParse(timeParts[1]) ?? 0;
        if (minutes >= 0 && seconds >= 0 && seconds < 60) {
          duration = Duration(minutes: minutes, seconds: seconds);
        }
      }
    }

    return AudioMessageItem(
      audioUrl: mediaUrl ?? '',
      duration: duration ?? const Duration(seconds: 30), // Default duration
      isMe: isMe,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
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

  Widget _buildRecalledMessage(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              gradient: isMe 
                  ? const LinearGradient(
                      colors: [Color(0xFFFF6B9D), Color(0xFFFF8E9E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade200, Colors.grey.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(18.0).copyWith(
                bottomRight: isMe ? const Radius.circular(4.0) : null,
                bottomLeft: !isMe ? const Radius.circular(4.0) : null,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.grey.shade400.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.replay_circle_filled,
                    size: 16,
                    color: isMe ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isMe ? '💕 You recalled this message' : '💔 This message was recalled',
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.grey.shade700,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to learn more',
                        style: TextStyle(
                          color: isMe 
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.grey.shade500,
                          fontSize: 11.0,
                          fontStyle: FontStyle.italic,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageFooter(ThemeData theme) {
    final timeFormat = DateFormat('HH:mm');
    final formattedTime = timeFormat.format(timestamp);

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, bottom: 8.0, left: 16.0, top: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: isMe 
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.grey.shade100.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 10.0,
                    color: isMe ? Colors.white.withValues(alpha: 0.9) : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 6.0),
                  Icon(
                    status == MessageStatus.read 
                        ? Icons.done_all_rounded
                        : status == MessageStatus.delivered
                            ? Icons.done_all_rounded
                            : status == MessageStatus.sent
                                ? Icons.done_rounded
                                : Icons.access_time_rounded,
                    size: 12.0,
                    color: status == MessageStatus.read 
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ],
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
