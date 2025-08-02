// filepath: c:\amoura-final-project\mobile-app\lib\presentation\chat\conversation\chat_conversation_view.dart
import 'package:flutter/material.dart';
import '../../../config/language/app_localizations.dart';
import '../../../data/models/chat/message_model.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input.dart';
import 'widgets/pinned_messages_section.dart';

class ChatConversationView extends StatefulWidget {
  final int conversationId;
  final String recipientName;
  final String? recipientAvatarUrl;
  final bool isOnline;

  const ChatConversationView({
    super.key,
    required this.conversationId,
    required this.recipientName,
    this.recipientAvatarUrl,
    this.isOnline = false,
  });

  @override
  State<ChatConversationView> createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<ChatConversationView> {
  final ScrollController _scrollController = ScrollController();

  // Mock data for demonstration purposes
  // In a real app, these would come from a ViewModel or state management solution
  final List<MessageModel> _messages = [];
  final List<MessageModel> _pinnedMessages = [];
  MessageModel? _replyingToMessage;
  MessageModel? _editingMessage;
  bool _isLoading = true;
  final bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    // Simulate loading messages from an API
    setState(() {
      _isLoading = true;
    });

    // In a real app, this would be a call to your data repository
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    final now = DateTime.now();
    if (!mounted) return;
    final localizations = AppLocalizations.of(context);
    final List<MessageModel> loadedMessages = [
      MessageModel(
        id: 1,
        senderId: 1, // current user
        receiverId: 2,
        content: localizations.translate('mock_message_1'),
        messageTypeId: 1,
        isRead: true,
        isEdited: false,
        isRecalled: false,
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      MessageModel(
        id: 2,
        senderId: 2, // recipient
        receiverId: 1,
        content: localizations.translate('mock_message_2'),
        messageTypeId: 1,
        isRead: true,
        isEdited: false,
        isRecalled: false,
        createdAt: now.subtract(const Duration(minutes: 28)),
      ),
      MessageModel(
        id: 3,
        senderId: 1,
        receiverId: 2,
        content: localizations.translate('mock_message_3'),
        messageTypeId: 1,
        isRead: true,
        isEdited: true,
        editedAt: now.subtract(const Duration(minutes: 24)),
        isRecalled: false,
        createdAt: now.subtract(const Duration(minutes: 25)),
      ),
      MessageModel(
        id: 4,
        senderId: 2,
        receiverId: 1,
        content: localizations.translate('mock_message_4'),
        messageTypeId: 1,
        isRead: true,
        isEdited: false,
        isRecalled: false,
        createdAt: now.subtract(const Duration(minutes: 20)),
      ),
      MessageModel(
        id: 5,
        senderId: 2,
        receiverId: 1,
        content: localizations.translate('chat_prototype_message'),
        messageTypeId: 1,
        isRead: false,
        isEdited: false,
        isRecalled: false,
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
    ];

    // Mock pinned message
    final pinnedMessage = MessageModel(
      id: 2,
      senderId: 2,
      receiverId: 1,
      content: "I'm good, thanks! Just working on a new project.",
      messageTypeId: 1,
      isRead: true,
      isEdited: false,
      isRecalled: false,
      createdAt: now.subtract(const Duration(minutes: 28)),
    );

    setState(() {
      _messages.addAll(loadedMessages);
      _pinnedMessages.add(pinnedMessage);
      _isLoading = false;
    });

    // Scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSendMessage(String text) {
    // Create a new message
    final newMessage = MessageModel(
      id: _messages.length + 1,
      senderId: 1, // Current user ID
      receiverId: 2, // Recipient ID
      content: text,
      messageTypeId: 1, // Text message
      isRead: false,
      isEdited: false,
      isRecalled: false,
      createdAt: DateTime.now(),
    );

    if (_editingMessage != null) {
      // Handle editing existing message
      final index = _messages.indexWhere(
        (msg) => msg.id == _editingMessage!.id,
      );
      if (index != -1) {
        final updatedMessage = MessageModel(
          id: _editingMessage!.id,
          senderId: _editingMessage!.senderId,
          receiverId: _editingMessage!.receiverId,
          content: text,
          messageTypeId: _editingMessage!.messageTypeId,
          isRead: _editingMessage!.isRead,
          isEdited: true,
          editedAt: DateTime.now(),
          isRecalled: false,
          createdAt: _editingMessage!.createdAt,
          updatedAt: DateTime.now(),
        );

        setState(() {
          _messages[index] = updatedMessage;
          _editingMessage = null;
        });
      }
    } else {
      // Send new message
      setState(() {
        _messages.add(newMessage);
        _replyingToMessage = null;
      });
    }

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _handleLongPressMessage(MessageModel message) {
    if (!context.mounted) return;
    if (message.senderId == 1) {
      // Current user ID
      _showMessageOptionsForOwnMessage(message);
    } else {
      _showMessageOptionsForOtherMessage(message);
    }
  }

  void _showMessageOptionsForOwnMessage(MessageModel message) {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.reply),
                  title: Text(localizations.translate('reply')),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _replyingToMessage = message;
                      _editingMessage = null;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(localizations.translate('edit')),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _editingMessage = message;
                      _replyingToMessage = null;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.push_pin),
                  title: Text(_isPinned(message) ? 'Unpin' : 'Pin'),
                  onTap: () {
                    Navigator.pop(context);
                    _togglePinMessage(message);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    localizations.translate('delete'),
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMessage(message);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showMessageOptionsForOtherMessage(MessageModel message) {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.reply),
                  title: Text(localizations.translate('reply')),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _replyingToMessage = message;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.push_pin),
                  title: Text(_isPinned(message) ? 'Unpin' : 'Pin'),
                  onTap: () {
                    Navigator.pop(context);
                    _togglePinMessage(message);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: Text(localizations.translate('copy')),
                  onTap: () {
                    Navigator.pop(context);
                    // Copy message text to clipboard
                  },
                ),
              ],
            ),
          ),
    );
  }

  bool _isPinned(MessageModel message) {
    return _pinnedMessages.any((msg) => msg.id == message.id);
  }

  void _togglePinMessage(MessageModel message) {
    setState(() {
      if (_isPinned(message)) {
        _pinnedMessages.removeWhere((msg) => msg.id == message.id);
      } else {
        _pinnedMessages.add(message);
      }
    });
  }

  void _deleteMessage(MessageModel message) {
    setState(() {
      _messages.removeWhere((msg) => msg.id == message.id);
      if (_isPinned(message)) {
        _pinnedMessages.removeWhere((msg) => msg.id == message.id);
      }
    });
  }

  void _navigateToPinnedMessage(MessageModel message) {
    final index = _messages.indexWhere((msg) => msg.id == message.id);
    if (index != -1) {
      // Scroll to the message (would need to implement a more complex solution
      // in a real app to calculate exact scroll position)
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
              ),
              child:
                  widget.recipientAvatarUrl != null &&
                          widget.recipientAvatarUrl!.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          widget.recipientAvatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Center(
                                child: Text(
                                  widget.recipientName.isNotEmpty
                                      ? widget.recipientName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        ),
                      )
                      : Center(
                        child: Text(
                          widget.recipientName.isNotEmpty
                              ? widget.recipientName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
            ),
            const SizedBox(width: 8),

            // Name and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.recipientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isOnline ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_isTyping) ...[
                      const SizedBox(width: 4),
                      const Text(
                        '• Typing...',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // Handle voice call
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // Handle video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show chat options menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Pinned messages section
          if (_pinnedMessages.isNotEmpty)
            PinnedMessagesSection(
              pinnedMessages: _pinnedMessages,
              onTapPinnedMessage: _navigateToPinnedMessage,
              onUnpinMessage: _togglePinMessage,
            ),

          // Messages list
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 8.0),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isMyMessage =
                            message.senderId == 1; // Current user ID

                        // Show date separator (would need to implement logic to determine when to show)
                        bool showDateSeparator =
                            index == 0 ||
                            !_isSameDay(
                              _messages[index].createdAt,
                              _messages[index - 1].createdAt,
                            );

                        return Column(
                          children: [
                            if (showDateSeparator)
                              _buildDateSeparator(message.createdAt),
                            MessageBubble(
                              message: message,
                              isMyMessage: isMyMessage,
                              senderName:
                                  isMyMessage ? 'You' : widget.recipientName,
                              senderAvatarUrl:
                                  isMyMessage
                                      ? null
                                      : widget.recipientAvatarUrl,
                              onMessageLongPress: _handleLongPressMessage,
                              onDoubleTap:
                                  (msg) => setState(() {
                                    _replyingToMessage = msg;
                                  }),
                            ),
                          ],
                        );
                      },
                    ),
          ),

          // Message input
          MessageInput(
            onSendMessage: _handleSendMessage,
            onAttachmentTap: () {
              // Handle attachment functionality
            },
            onCameraTap: () {
              // Handle camera functionality
            },
            isReplying: _replyingToMessage != null,
            replyingTo: _replyingToMessage?.content,
            onCancelReply:
                () => setState(() {
                  _replyingToMessage = null;
                }),
            isEditing: _editingMessage != null,
            editingText: _editingMessage?.content,
            onCancelEdit:
                () => setState(() {
                  _editingMessage = null;
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _formatDate(date),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(child: Divider()),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
