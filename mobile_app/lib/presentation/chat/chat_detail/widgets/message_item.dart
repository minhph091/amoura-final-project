import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/message.dart';
import '../../../../core/utils/url_transformer.dart';
import 'audio_message_item.dart';
import 'video_message_item.dart';
import 'full_screen_image_viewer.dart';

class MessageItem extends StatefulWidget {
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
  final VoidCallback? onMessageTap;
  final Function()? onTapRepliedMessage;
  final VoidCallback? onSwipeReply;
  final String? mediaUrl;
  final String? fileInfo;
  final bool recalled;
  final bool isRead;
  final DateTime? readAt;
  final bool isLatestSentMessage; // thêm biến này

  const MessageItem({
    super.key,
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
    this.onMessageTap,
    this.onTapRepliedMessage,
    this.onSwipeReply,
    this.mediaUrl,
    this.fileInfo,
    this.recalled = false,
    this.isRead = false,
    this.readAt,
    this.isLatestSentMessage = false, // default false
  });

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  bool _showReadStatus = false;

  void _toggleReadStatus() {
    // Only show read status for current user's read messages
    if (widget.isMe && widget.isRead && widget.readAt != null) {
      setState(() {
        _showReadStatus = !_showReadStatus;
      });

      // Auto-hide after 3 seconds
      if (_showReadStatus) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showReadStatus = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for other user messages (not shown for current user)
          if (!widget.isMe) _buildAvatar(),

          // Message bubble with swipe-to-reply
          _buildSwipeableMessage(maxWidth, theme),

          // Space after message bubble
          const SizedBox(width: 4.0),

          // Status indicator for current user's messages
          if (widget.isMe) _buildStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildSwipeableMessage(double maxWidth, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        // Only handle tap for current user's messages to show read status
        if (widget.isMe) {
          _toggleReadStatus(); // Use internal method instead of callback
        }
      },
      onLongPress: widget.onLongPress,
      onDoubleTap: widget.onDoubleTap,
      onHorizontalDragEnd: (details) {
        // Swipe to reply functionality
        if (widget.onSwipeReply != null) {
          // Detect swipe direction and distance
          final primaryVelocity = details.primaryVelocity ?? 0;

          // For other user's messages: swipe right to reply
          // For own messages: swipe left to reply
          if ((!widget.isMe && primaryVelocity > 500) ||
              (widget.isMe && primaryVelocity < -500)) {
            debugPrint(
              'MessageItem: Swipe to reply detected - isMe: ${widget.isMe}, velocity: $primaryVelocity',
            );
            widget.onSwipeReply!();
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message content
          _buildMessageContent(maxWidth, theme),

          // Simple "Seen" text for read messages
          if (_showReadStatus &&
              widget.isMe &&
              widget.isRead &&
              widget.readAt != null)
            _buildSeenIndicator(theme),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final transformedAvatarUrl = UrlTransformer.transformAvatarUrl(
      widget.senderAvatar,
    );
    debugPrint(
      'MessageItem: Building avatar for ${widget.senderName} with URL: $transformedAvatarUrl',
    );

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
          child:
              transformedAvatarUrl.isNotEmpty
                  ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.0),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        transformedAvatarUrl,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                            'MessageItem: Error loading avatar for ${widget.senderName}: $error',
                          );
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
                                widget.senderName.isNotEmpty
                                    ? widget.senderName[0].toUpperCase()
                                    : "?",
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
                            debugPrint(
                              'MessageItem: Avatar loaded successfully for ${widget.senderName}',
                            );
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFF6B9D),
                                  ),
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
                      widget.senderName.isNotEmpty
                          ? widget.senderName[0].toUpperCase()
                          : "?",
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

  Widget _buildMessageContent(double maxWidth, ThemeData theme) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth * 0.8, minWidth: 50),
      decoration: BoxDecoration(
        color:
            widget.isMe ? theme.colorScheme.primary : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reply section - hiển thị tin nhắn được reply (mờ)
          if (widget.replyToMessage != null &&
              widget.replyToMessage!.isNotEmpty)
            _buildReplySection(theme),

          // Message content
          _buildMainContent(theme),

          // Message footer with time, status, and "Seen" indicator
          _buildMessageFooter(theme),
        ],
      ),
    );
  }

  /// Build reply section showing the original message being replied to
  Widget _buildReplySection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (widget.isMe ? Colors.white : Colors.grey.shade600).withValues(
          alpha: 0.15,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color:
                widget.isMe
                    ? Colors.white.withValues(alpha: 0.6)
                    : theme.colorScheme.primary.withValues(alpha: 0.6),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original sender name
          if (widget.replyToSender != null && widget.replyToSender!.isNotEmpty)
            Text(
              widget.replyToSender!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    widget.isMe
                        ? Colors.white.withValues(alpha: 0.8)
                        : theme.colorScheme.primary.withValues(alpha: 0.8),
              ),
            ),

          const SizedBox(height: 2),

          // Original message content (dimmed/mờ)
          Text(
            widget.replyToMessage!,
            style: TextStyle(
              fontSize: 13,
              color:
                  widget.isMe
                      ? Colors.white.withValues(alpha: 0.7)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    if (widget.recalled) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.undo,
              size: 16,
              color:
                  widget.isMe
                      ? Colors.white.withValues(alpha: 0.7)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              'This message was recalled',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color:
                    widget.isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    switch (widget.type) {
      case MessageType.image:
        return _buildImageContent(theme);
      case MessageType.video:
        return _buildVideoContent(theme);
      case MessageType.audio:
        return _buildAudioContent(theme);
      case MessageType.file:
        return _buildFileContent(theme);
      default:
        return _buildTextContent(theme);
    }
  }

  Widget _buildImageContent(ThemeData theme) {
    // Transform URL for Android emulator compatibility
    final transformedImageUrl = UrlTransformer.transformImageUrl(
      widget.mediaUrl ?? '',
    );
    debugPrint(
      'MessageItem: Building image message with URL: ${widget.mediaUrl} -> $transformedImageUrl',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder:
              (context) => GestureDetector(
                onTap: () {
                  if (transformedImageUrl.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => FullScreenImageViewer(
                              imageUrl: widget.mediaUrl!,
                              caption:
                                  (widget.message.isNotEmpty &&
                                          widget.message != 'Photo')
                                      ? widget.message
                                      : null,
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
                  child:
                      transformedImageUrl.isNotEmpty
                          ? Image.network(
                            transformedImageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint(
                                'MessageItem: Error loading image: $error',
                              );
                              debugPrint(
                                'MessageItem: Image URL: $transformedImageUrl',
                              );
                              return Container(
                                width: double.infinity,
                                height: 150,
                                color: Colors.grey.shade300,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                debugPrint(
                                  'MessageItem: Image loaded successfully',
                                );
                                return child;
                              }
                              return SizedBox(
                                width: double.infinity,
                                height: 150,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
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
                                const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'No image URL',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ),
        ),
        if (widget.message.isNotEmpty && widget.message != 'Photo')
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              gradient:
                  widget.isMe
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
              widget.message,
              style: TextStyle(
                color: widget.isMe ? Colors.white : Colors.grey.shade800,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoContent(ThemeData theme) {
    // Extract file size and duration from message content or fileInfo
    String? fileSize;
    Duration? duration;

    // Parse fileInfo if available (format: "filename.mp4 • 5.2 MB • 2:30")
    if (widget.fileInfo != null) {
      final parts = widget.fileInfo!.split(' • ');
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
      videoUrl: widget.mediaUrl ?? '',
      thumbnailUrl: widget.mediaUrl, // Use same URL for thumbnail for now
      duration: duration,
      fileSize: fileSize,
      isMe: widget.isMe,
      onLongPress: widget.onLongPress,
      onDoubleTap: widget.onDoubleTap,
    );
  }

  Widget _buildAudioContent(ThemeData theme) {
    // Extract duration from fileInfo if available (format: "voice_note.m4a • 3.2 MB • 1:45")
    Duration? duration;

    if (widget.fileInfo != null) {
      final parts = widget.fileInfo!.split(' • ');
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
    if (duration == null && widget.message.contains(':')) {
      final timeParts = widget.message.split(':');
      if (timeParts.length == 2) {
        final minutes = int.tryParse(timeParts[0]) ?? 0;
        final seconds = int.tryParse(timeParts[1]) ?? 0;
        if (minutes >= 0 && seconds >= 0 && seconds < 60) {
          duration = Duration(minutes: minutes, seconds: seconds);
        }
      }
    }

    return AudioMessageItem(
      audioUrl: widget.mediaUrl ?? '',
      duration: duration ?? const Duration(seconds: 30), // Default duration
      isMe: widget.isMe,
      onLongPress: widget.onLongPress,
      onDoubleTap: widget.onDoubleTap,
    );
  }

  Widget _buildFileContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color:
                  widget.isMe
                      ? Colors.white24
                      : theme.dividerColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.description,
              color: widget.isMe ? Colors.white : theme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.isNotEmpty ? widget.message : "File",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        widget.isMe
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.fileInfo != null)
                  Text(
                    widget.fileInfo!,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          widget.isMe
                              ? Colors.white70
                              : theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
      child: Text(
        widget.message,
        style: TextStyle(
          color: widget.isMe ? Colors.white : Colors.grey.shade800,
          fontSize: 15.0,
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  /// Build simple "Seen" indicator (like Tinder)
  Widget _buildSeenIndicator(ThemeData theme) {
    final readTime = DateFormat('HH:mm').format(widget.readAt!);

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Seen $readTime',
            style: TextStyle(
              fontSize: 11.0,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageFooter(ThemeData theme) {
    final timeFormat = DateFormat('HH:mm');
    final formattedTime = timeFormat.format(widget.timestamp);

    return Padding(
      padding: const EdgeInsets.only(
        right: 16.0,
        bottom: 8.0,
        left: 16.0,
        top: 4.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            decoration: BoxDecoration(
              color:
                  widget.isMe
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
                    color:
                        widget.isMe
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                // ĐÃ XOÁ TOÀN BỘ ICON CHECKMARK Ở ĐÂY
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    // Chỉ hiển thị icon nếu là tin nhắn gửi gần nhất của mình
    if (!(widget.isMe && widget.isLatestSentMessage)) {
      return const SizedBox.shrink();
    }
    Widget statusIcon;

    switch (widget.status) {
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
        statusIcon = const Icon(Icons.check, size: 14, color: Colors.grey);
        break;
      case MessageStatus.delivered:
        statusIcon = const Icon(Icons.done_all, size: 14, color: Colors.grey);
        break;
      case MessageStatus.read:
        statusIcon = const Icon(Icons.done_all, size: 14, color: Colors.blue);
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
