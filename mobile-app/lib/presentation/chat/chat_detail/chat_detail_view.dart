import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'chat_detail_viewmodel.dart';
import 'widgets/chat_header.dart';
import 'widgets/message_input.dart';
import 'widgets/message_item.dart';
import 'widgets/call_button.dart';
import '../../../domain/models/chat.dart';
import '../../../domain/models/message.dart';
import '../../../app/di/injection.dart';
import '../../../domain/usecases/chat/get_chat_room_usecase.dart';
import '../../shared/widgets/app_gradient_background.dart';

class ChatDetailView extends StatefulWidget {
  final String chatId;
  final String recipientName;
  final String? recipientAvatar;
  final bool isOnline;

  const ChatDetailView({
    super.key,
    required this.chatId,
    required this.recipientName,
    this.recipientAvatar,
    this.isOnline = false,
  });

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  late final ScrollController _scrollController;
  late final ChatDetailViewModel _viewModel;
  bool _showScrollToBottom = false;
  bool _isReplying = false;
  String? _replyingToMessage;
  bool _isEditing = false;
  String? _editingMessageId;
  String? _editingText;
  final _messageFocusNode = FocusNode();
  
  // Thêm state để lưu thông tin chat room
  Chat? _chatRoom;
  bool _isLoadingChatInfo = true;
  String? _chatInfoError;
  bool _isInitialized = false;
  bool _hasMarkedAsRead = false; // Flag để tránh mark messages as read nhiều lần

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    
    // Khởi tạo viewModel trong initState
    _viewModel = ChatDetailViewModel();

    // Load chat room info and messages when view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatRoomInfo();
      _viewModel.loadMessages(widget.chatId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Chỉ setup một lần khi view được tạo
    if (!_isInitialized) {
      _isInitialized = true;
      
      // Setup listener một lần duy nhất để tự động mark messages as read khi messages được load
      _viewModel.addListener(_onViewModelChanged);
    }
  }

  /// Listener cho ViewModel changes - chỉ mark as read một lần
  void _onViewModelChanged() {
    if (!_viewModel.isLoading && 
        _viewModel.messages.isNotEmpty && 
        !_hasMarkedAsRead) {
      // Delay một chút để đảm bảo UI đã render
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && !_hasMarkedAsRead) {
          _hasMarkedAsRead = true;
          _markMessagesAsRead();
        }
      });
    }
  }

  /// Đánh dấu tin nhắn đã đọc
  /// Gọi ngay khi user vào chat room và khi scroll đến bottom
  void _markMessagesAsRead() {
    if (widget.chatId.isNotEmpty) {
      debugPrint('ChatDetailView: Marking messages as read for chat ${widget.chatId}');
      _viewModel.markMessagesAsRead(widget.chatId);
    }
  }

  Future<void> _loadChatRoomInfo() async {
    try {
      setState(() {
        _isLoadingChatInfo = true;
        _chatInfoError = null;
      });

      // Debug logging để xác định vấn đề
      debugPrint('ChatDetailView: Loading chat room info for chatId: ${widget.chatId}');
      debugPrint('ChatDetailView: Recipient name: ${widget.recipientName}');
      debugPrint('ChatDetailView: Recipient avatar: ${widget.recipientAvatar}');

      // Lấy thông tin chat room từ usecase
      final getChatRoomUseCase = getIt<GetChatRoomUseCase>();
      final chatRoom = await getChatRoomUseCase.execute(widget.chatId);
      
      debugPrint('ChatDetailView: Chat room loaded successfully');
      debugPrint('ChatDetailView: Chat room data - ID: ${chatRoom.id}, User1: ${chatRoom.user1Name}, User2: ${chatRoom.user2Name}');
      
      setState(() {
        _chatRoom = chatRoom;
        _isLoadingChatInfo = false;
      });
    } catch (e) {
      debugPrint('ChatDetailView: Error loading chat room info: $e');
      debugPrint('ChatDetailView: Error type: ${e.runtimeType}');
      
      // Nếu là lỗi 404, có thể chat room chưa được tạo hoặc có delay
      // Sử dụng thông tin từ navigation arguments làm fallback
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        debugPrint('ChatDetailView: Chat room not found (404), using fallback mode with navigation arguments');
        setState(() {
          _chatRoom = null; // Sẽ dùng thông tin từ widget properties
          _isLoadingChatInfo = false;
          _chatInfoError = null; // Clear error để có thể sử dụng chat bình thường
        });
        
        // Retry sau 3 giây nếu chat room chưa sẵn sàng
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _chatRoom == null) {
            debugPrint('ChatDetailView: Retrying to load chat room after delay...');
            _loadChatRoomInfo();
          }
        });
      } else {
        setState(() {
          _chatInfoError = e.toString();
          _isLoadingChatInfo = false;
        });
      }
    }
  }

  // Getter để lấy thông tin recipient từ chat room
  String get recipientName {
    if (_chatRoom != null) {
      return _chatRoom!.participantName ?? widget.recipientName;
    }
    return widget.recipientName;
  }

  String? get recipientAvatar {
    if (_chatRoom != null) {
      return _chatRoom!.participantAvatar;
    }
    return widget.recipientAvatar;
  }

  bool get isOnline {
    // TODO: Implement online status check
    return widget.isOnline;
  }

  void _scrollListener() {
    final showScrollToBottom = _scrollController.offset > 200;
    if (showScrollToBottom != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = showScrollToBottom;
      });
    }

    // Chỉ auto-mark khi user scroll về bottom và chưa mark lần nào
    if (_scrollController.offset <= 50 && !_hasMarkedAsRead) { // Near bottom (reverse list)
      _hasMarkedAsRead = true;
      _markMessagesAsRead();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _startReply(String message, String senderName) {
    setState(() {
      _isReplying = true;
      _replyingToMessage = message;
      _isEditing = false;
      _editingMessageId = null;
      _editingText = null;
    });
    _messageFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _isReplying = false;
      _replyingToMessage = null;
    });
  }

  void _startEdit(String messageId, String text) {
    setState(() {
      _isEditing = true;
      _editingMessageId = messageId;
      _editingText = text;
      _isReplying = false;
      _replyingToMessage = null;
    });
    _messageFocusNode.requestFocus();
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _editingMessageId = null;
      _editingText = null;
    });
  }

  void _showMessageOptions(Message message) {
    // Using the Message class directly instead of MessageItem
    final viewModel = _viewModel;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(context);
                  _startReply(message.content, message.senderName);
                },
              ),
              if (message.senderId == viewModel.currentUserId)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _startEdit(message.id, message.content);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.content_copy),
                title: const Text('Copy'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              if (message.senderId == viewModel.currentUserId && !message.recalled)
                ListTile(
                  leading: const Icon(Icons.undo, color: Colors.orange),
                  title: const Text('Recall message', style: TextStyle(color: Colors.orange)),
                  onTap: () {
                    Navigator.pop(context);
                    _showRecallConfirmation(message);
                },
              ),
              if (message.senderId == viewModel.currentUserId)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(message);
                  },
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showRecallConfirmation(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recall Message?'),
        content: const Text(
          'This message will be recalled for everyone. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Recall message
              _viewModel.recallMessage(message.id);
            },
            child: const Text('Recall', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message?'),
        content: const Text('This message will be deleted for everyone. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete message
              _viewModel.deleteMessage(message.id);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ChatDetailViewModel>(
        builder: (context, viewModel, child) {
          return AppGradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                        title: _isLoadingChatInfo 
            ? const Text('Loading...')
            : _chatInfoError != null
                ? const Text('Chat')
                : Row(
                    children: [
                      // User avatar với improved error handling
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade300,
                        child: recipientAvatar != null && recipientAvatar!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  recipientAvatar!,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('Error loading avatar: $error');
                                    return Text(
                                      recipientName.isNotEmpty ? recipientName[0].toUpperCase() : "?",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                recipientName.isNotEmpty ? recipientName[0].toUpperCase() : "?",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              recipientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (viewModel.lastActiveTime != null)
                              Text(
                                viewModel.lastActiveTime!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).hintColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                actions: [
                  if (!_isLoadingChatInfo && _chatInfoError == null) ...[
                    IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () {
                        // Voice call functionality
                      },
                      iconSize: 22,
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam),
                      onPressed: () {
                        // Video call functionality
                      },
                      iconSize: 22,
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        // Show chat options
                        _showChatOptions();
                      },
                      iconSize: 22,
                    ),
                  ],
                ],
              ),
              body: _isLoadingChatInfo
                  ? const Center(child: CircularProgressIndicator())
                  : _chatInfoError != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading chat',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _chatInfoError!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: _loadChatRoomInfo,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : Column(
                children: [
                  // Pinned messages section
                  if (viewModel.pinnedMessages.isNotEmpty)
                    _buildPinnedMessagesSection(viewModel),

                  // Chat messages
                  Expanded(
                    child: Stack(
                      children: [
                        // Messages list
                        _buildMessagesView(viewModel),

                        // Scroll to bottom button
                        if (_showScrollToBottom)
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: FloatingActionButton(
                              mini: true,
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              onPressed: _scrollToBottom,
                              child: const Icon(Icons.arrow_downward, size: 20),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Date indicator (today, yesterday, etc)
                  if (viewModel.showDateIndicator)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        _formatDateIndicator(viewModel.currentDateIndicator),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                        ),
                      ),
                    ),

                  // Typing indicator
                  if (viewModel.isTyping)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 8),
                      child: Row(
                        children: [
                          Text(
                                      '$recipientName is typing',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 5),
                          _buildTypingIndicator(),
                        ],
                      ),
                    ),

                  // Message input
                  MessageInput(
                    focusNode: _messageFocusNode,
                    onSendMessage: (message) {
                      if (_isEditing && _editingMessageId != null) {
                        // Edit existing message
                        viewModel.editMessage(
                          _editingMessageId!,
                          message,
                        );
                        _cancelEdit();
                      } else {
                        // Send new message, possibly a reply
                        viewModel.sendMessage(
                          chatId: widget.chatId,
                          message: message,
                          replyToMessageId: _isReplying ? _replyingToMessage : null,
                        );
                        if (_isReplying) _cancelReply();
                      }
                      _scrollToBottom();
                    },
                    onAttachmentTap: () {
                      _showAttachmentOptions();
                    },
                    onCameraTap: () {
                      // Handle camera tap action
                      _openCamera();
                    },
                    onLikeTap: () {
                      // Send quick like/heart
                      viewModel.sendMessage(
                        chatId: widget.chatId,
                        message: '❤️',
                      );
                    },
                    isReplying: _isReplying,
                    replyingTo: _replyingToMessage,
                    onCancelReply: _cancelReply,
                    isEditing: _isEditing,
                    editingText: _editingText,
                    onCancelEdit: _cancelEdit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesView(ChatDetailViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation by sending a message',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      itemCount: viewModel.messages.length,
      itemBuilder: (context, index) {
        final message = viewModel.messages[index];

        // Convert domain Message to UI MessageItem
        return MessageItem(
          message: message.content,
          senderName: message.senderName,
          senderAvatar: message.senderAvatar,
          timestamp: message.timestamp,
          isMe: message.senderId == viewModel.currentUserId,
          status: message.status,
          type: message.type,
          replyToMessage: message.replyToMessage,
          replyToSender: message.replyToSenderName,
          onLongPress: () => _showMessageOptions(message),
          onDoubleTap: () {
            // Quick reaction
            viewModel.addReaction(message.id, '👍');
          },
          onTapRepliedMessage: message.replyToMessageId != null
              ? () => viewModel.scrollToMessage(message.replyToMessageId!)
              : null,
          mediaUrl: message.mediaUrl,
          fileInfo: message.fileInfo,
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return SizedBox(
      width: 35,
      child: Row(
        children: List.generate(
          3,
              (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withAlpha(153),
              shape: BoxShape.circle,
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          ).scaleY(
            begin: 0.5,
            end: 1.0,
            duration: const Duration(milliseconds: 600),
            delay: Duration(milliseconds: (index * 150)),
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }

  String _formatDateIndicator(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateToCheck).inDays < 7) {
      final format = DateFormat('EEEE'); // Day name
      return format.format(date);
    } else {
      final format = DateFormat('MMM d, y'); // Month day, year
      return format.format(date);
    }
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search'),
                onTap: () {
                  Navigator.pop(context);
                  // Search implementation
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Mute notifications'),
                onTap: () {
                  Navigator.pop(context);
                  // Mute implementation
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('View media, files and links'),
                onTap: () {
                  Navigator.pop(context);
                  // View media implementation
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete chat', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteChat();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat?'),
        content: const Text('This will delete all messages in this chat. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to chat list
              // Delete chat implementation
              // _viewModel.deleteChat(widget.chatId);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAttachmentOption(
                      icon: Icons.image,
                      color: Colors.purple,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _selectFromGallery();
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.camera_alt,
                      color: Colors.red,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _openCamera();
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.insert_drive_file,
                      color: Colors.blue,
                      label: 'Document',
                      onTap: () {
                        Navigator.pop(context);
                        _selectDocument();
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.location_on,
                      color: Colors.green,
                      label: 'Location',
                      onTap: () {
                        Navigator.pop(context);
                        _shareLocation();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _selectFromGallery() {
    // Implement gallery selection
    _viewModel.selectImageFromGallery(widget.chatId);
  }

  void _openCamera() {
    // Implement camera functionality
    _viewModel.takePicture(widget.chatId);
  }

  void _selectDocument() {
    // Implement document selection
    _viewModel.selectDocument(widget.chatId);
  }

  void _shareLocation() {
    // Implement location sharing
    _viewModel.shareCurrentLocation(widget.chatId);
  }

  Widget _buildPinnedMessagesSection(ChatDetailViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          if (viewModel.pinnedMessages.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "${viewModel.currentPinnedMessageIndex + 1}/${viewModel.pinnedMessages.length}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 14),
                    onPressed: () {
                      // Cycle to next pinned message
                      viewModel.showNextPinnedMessage();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                  ),
                ],
              ),
            ),
          ListTile(
            leading: const Icon(Icons.push_pin),
            title: Text(
              viewModel.currentPinnedMessage?.senderName ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            subtitle: Text(
              viewModel.currentPinnedMessage?.content ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                // Option to unpin this specific message or all messages
                _showUnpinOptions(viewModel);
              },
            ),
            onTap: () {
              // Scroll to the pinned message in chat
              if (viewModel.currentPinnedMessage != null) {
                viewModel.scrollToMessage(viewModel.currentPinnedMessage!.id);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showUnpinOptions(ChatDetailViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.push_pin_outlined),
                title: const Text('Unpin this message'),
                onTap: () {
                  Navigator.pop(context);
                  if (viewModel.currentPinnedMessage != null) {
                    viewModel.unpinMessage(viewModel.currentPinnedMessage!.id);
                  }
                },
              ),
              if (viewModel.pinnedMessages.length > 1)
                ListTile(
                  leading: const Icon(Icons.format_clear),
                  title: const Text('Unpin all messages'),
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.unpinAllMessages();
                  },
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _viewModel.removeListener(_onViewModelChanged); // Remove listener trước khi dispose
    _viewModel.dispose(); // Dispose viewModel
    super.dispose();
  }
}

