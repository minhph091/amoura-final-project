import 'package:flutter/material.dart';
import '../../../config/language/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';

import 'chat_detail_viewmodel.dart';
import 'widgets/message_input.dart';
import 'widgets/message_item.dart';
import '../../../domain/models/chat.dart';
import '../../../domain/models/message.dart';
import '../../../app/di/injection.dart';
import '../../../domain/usecases/chat/get_chat_room_usecase.dart';
import '../../shared/widgets/app_gradient_background.dart';
import '../../../core/utils/url_transformer.dart';
import 'package:collection/collection.dart'; // Added for firstWhereOrNull

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
  String? _replyingToMessageId;
  String? _replyingToSender;
  bool _isEditing = false;
  String? _editingMessageId;
  String? _editingText;
  final _messageFocusNode = FocusNode();

  // Thêm state để lưu thông tin chat room
  Chat? _chatRoom;
  bool _isLoadingChatInfo = true;
  String? _chatInfoError;
  bool _isInitialized = false;
  bool _hasMarkedAsRead =
      false; // Flag để tránh mark messages as read nhiều lần

  // Lưu lại prompt/tone AI gần nhất để có thể "Sửa lại" nhanh
  String? _lastAiPrompt;
  int _aiRetryCount = 0; // Tăng dần để yêu cầu AI tạo biến thể khác

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

  Future<String?> _aiEditFlow(String original) async {
    // Unified composer: nhập tin nhắn + chọn phong cách + xem kết quả/Retry/Accept trong một sheet
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final presets = <String>[
          'Lịch sự và ấm áp',
          'Ngắn gọn, súc tích',
          'Tự tin và duyên dáng',
          'Hài hước nhẹ nhàng',
          'Trang trọng',
          'Thả thính tinh tế',
        ];

        final messageController = TextEditingController(text: original);
        final promptController = TextEditingController(text: _lastAiPrompt ?? '');

        String? selectedPreset = _lastAiPrompt != null && presets.contains(_lastAiPrompt!) ? _lastAiPrompt : null;
        String? resultText;
        bool isLoading = false;
        int localRetry = 0;

        Future<void> runAi(Function(void Function()) setModalState) async {
          final input = messageController.text.trim();
          if (input.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nhập nội dung để AI đề xuất')),
            );
            return;
          }
          final basePrompt = (promptController.text.trim().isNotEmpty
                  ? promptController.text.trim()
                  : (selectedPreset ?? 'Tự nhiên, lịch sự'))
              .trim();
          setModalState(() { isLoading = true; });
          try {
            final seed = DateTime.now().microsecondsSinceEpoch.remainder(1000000);
            final effectivePrompt = localRetry == 0
                ? '$basePrompt [seed:$seed]'
                : '$basePrompt. Biến thể #${localRetry + 1} - tạo phiên bản khác, tự nhiên, không lặp lại. [seed:$seed]';
            final edited = await _viewModel.requestAiEdit(
              input,
              effectivePrompt,
              variant: localRetry,
              bypassCache: true,
            );
            setModalState(() {
              resultText = (edited ?? '').trim().isNotEmpty ? edited!.trim() : null;
              isLoading = false;
            });
            _lastAiPrompt = basePrompt;
            _aiRetryCount = localRetry;
          } catch (e) {
            setModalState(() { isLoading = false; });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('AI đang bận, thử lại sau')),
            );
          }
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottomInset + 16),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        const Icon(Icons.auto_fix_high, color: Color(0xFFFF6B9D)),
                        const SizedBox(width: 8),
                        const Text('Trợ lý AI gợi ý tin nhắn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Message input to edit/suggest
                    const Text('Nội dung tin nhắn'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: messageController,
                        maxLines: 4,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tin nhắn bạn muốn gửi hoặc mô tả tình huống...',
                          border: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Style presets
                    const Text('Chọn phong cách'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: presets.map((p) {
                        final isSelected = selectedPreset == p;
                        return ChoiceChip(
                          label: Text(p),
                          selected: isSelected,
                          onSelected: (_) {
                            setModalState(() {
                              selectedPreset = p;
                              // Áp dụng preset trực tiếp vào prompt để đảm bảo đổi phong cách
                              promptController.text = p;
                              // Reset vòng lặp biến thể khi đổi phong cách
                              localRetry = 0;
                              // Xoá kết quả cũ để tránh hiểu nhầm và chạy lại để cập nhật theo phong cách mới
                              resultText = null;
                            });
                            // Tự động tạo gợi ý mới theo phong cách vừa chọn
                            runAi(setModalState);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Custom prompt
                    const Text('Hoặc nhập yêu cầu cụ thể'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: promptController,
                      decoration: const InputDecoration(
                        hintText: 'Ví dụ: Lịch sự, mở đầu thân thiện và rủ đi cà phê cuối tuần',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                    const SizedBox(height: 12),

                    // Generate button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : () => runAi(setModalState),
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_fix_high),
                        label: Text(isLoading ? 'Đang tạo gợi ý...' : 'Tạo gợi ý'),
                      ),
                    ),

                    // Result section
                    if (resultText != null) ...[
                      const SizedBox(height: 16),
                      const Text('Gợi ý của AI'),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(resultText!, style: const TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      setModalState(() { localRetry += 1; });
                                      runAi(setModalState);
                                    },
                              child: const Text('Sửa lại'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, resultText),
                              child: const Text('Dùng tin nhắn này'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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

  /// Listener cho ViewModel changes - mark as read khi messages load xong
  void _onViewModelChanged() {
    if (!_viewModel.isLoading &&
        _viewModel.messages.isNotEmpty &&
        !_hasMarkedAsRead) {
      // Delay ngắn để đảm bảo UI đã render, sau đó mark as read
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_hasMarkedAsRead) {
          _hasMarkedAsRead = true;
          debugPrint(
            'ChatDetailView: Auto-marking messages as read after ${_viewModel.messages.length} messages loaded',
          );
          _markMessagesAsRead();
        }
      });
    }
  }

  /// Đánh dấu tin nhắn đã đọc
  /// Gọi ngay khi user vào chat room và khi scroll đến bottom
  void _markMessagesAsRead() {
    if (widget.chatId.isNotEmpty) {
      debugPrint(
        'ChatDetailView: Marking messages as read for chat ${widget.chatId}',
      );
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
      debugPrint(
        'ChatDetailView: Loading chat room info for chatId: ${widget.chatId}',
      );
      debugPrint('ChatDetailView: Recipient name: ${widget.recipientName}');
      debugPrint('ChatDetailView: Recipient avatar: ${widget.recipientAvatar}');

      // Lấy thông tin chat room từ usecase
      final getChatRoomUseCase = getIt<GetChatRoomUseCase>();
      final chatRoom = await getChatRoomUseCase.execute(widget.chatId);

      debugPrint('ChatDetailView: Chat room loaded successfully');
      debugPrint(
        'ChatDetailView: Chat room data - ID: ${chatRoom.id}, User1: ${chatRoom.user1Name}, User2: ${chatRoom.user2Name}',
      );

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
        debugPrint(
          'ChatDetailView: Chat room not found (404), using fallback mode with navigation arguments',
        );
        setState(() {
          _chatRoom = null; // Sẽ dùng thông tin từ widget properties
          _isLoadingChatInfo = false;
          _chatInfoError =
              null; // Clear error để có thể sử dụng chat bình thường
        });

        // Retry sau 3 giây nếu chat room chưa sẵn sàng
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _chatRoom == null) {
            debugPrint(
              'ChatDetailView: Retrying to load chat room after delay...',
            );
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

  // Getter để lấy thông tin recipient (participant - đối phương) từ chat room
  String get recipientName {
    if (_chatRoom != null && _viewModel.currentUserId.isNotEmpty) {
      // Nếu currentUserId là user1, lấy user2Name, ngược lại lấy user1Name
      if (_chatRoom!.user1Id == _viewModel.currentUserId) {
        return _chatRoom!.user2Name ?? widget.recipientName;
      } else {
        return _chatRoom!.user1Name ?? widget.recipientName;
      }
    }
    return widget.recipientName;
  }

  // Getter lấy avatar đối phương: ưu tiên từ _chatRoom, nếu không có thì lấy từ message đầu tiên của đối phương
  String? get recipientAvatar {
    if (_chatRoom != null && _viewModel.currentUserId.isNotEmpty) {
      final currentId = _viewModel.currentUserId.toString();
      final user1Id = _chatRoom!.user1Id?.toString();
      final user2Id = _chatRoom!.user2Id?.toString();
      // Nếu current user là user1, lấy avatar user2 (đối phương)
      if (user1Id == currentId && _chatRoom!.user2Avatar?.isNotEmpty == true) {
        return _chatRoom!.user2Avatar;
      }
      // Nếu current user là user2, lấy avatar user1 (đối phương)
      if (user2Id == currentId && _chatRoom!.user1Avatar?.isNotEmpty == true) {
        return _chatRoom!.user1Avatar;
      }
    }
    // Nếu không có avatar từ _chatRoom, lấy avatar từ message đầu tiên của đối phương
    final otherMsg = _viewModel.messages.firstWhereOrNull(
      (msg) => msg.senderId != _viewModel.currentUserId && (msg.senderAvatar?.isNotEmpty ?? false),
    );
    if (otherMsg != null) return otherMsg.senderAvatar;
    // Fallback cuối cùng
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
    if (_scrollController.offset <= 50 && !_hasMarkedAsRead) {
      // Near bottom (reverse list)
      _hasMarkedAsRead = true;
      _markMessagesAsRead();
    }

    // Pagination: Load more messages khi user scroll gần đến top (cuối conversation vì reverse=true)
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      // User đã scroll gần đến cuối danh sách, load thêm tin nhắn cũ hơn
      _loadMoreMessagesIfNeeded();
    }
  }

  /// Load thêm tin nhắn cũ hơn nếu cần và có thể
  void _loadMoreMessagesIfNeeded() {
    if (_viewModel.hasMoreMessages && !_viewModel.isLoadingMore) {
      debugPrint(
        'ChatDetailView: User scrolled to end, loading more messages...',
      );
      _viewModel.loadMoreMessages();
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

  /// Enhanced reply method that takes messageId
  void _startReplyWithId(String messageId, String message, String senderName) {
    setState(() {
      _isReplying = true;
      _replyingToMessage = message;
      _replyingToMessageId = messageId; // Store the actual message ID
      _replyingToSender = senderName;
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
      _replyingToMessageId = null;
      _replyingToSender = null;
    });
  }

  void _startEdit(String messageId, String text) {
    setState(() {
      _isEditing = true;
      _editingMessageId = messageId;
      _editingText = text;
      _isReplying = false;
      _replyingToMessage = null;
      _replyingToMessageId = null;
      _replyingToSender = null;
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.reply),
                title: Text(AppLocalizations.of(context).translate('reply')),
                onTap: () {
                  Navigator.pop(context);
                  _startReplyWithId(
                    message.id,
                    message.content,
                    message.senderName,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(AppLocalizations.of(context).translate('edit')),
                onTap: () {
                  Navigator.pop(context);
                  _startEdit(message.id, message.content);
                },
              ),
              ListTile(
                leading: const Icon(Icons.content_copy),
                title: Text(AppLocalizations.of(context).translate('copy')),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        ).translate('copied_to_clipboard'),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              if (message.senderId == viewModel.currentUserId)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(AppLocalizations.of(context).translate('edit')),
                  onTap: () {
                    Navigator.pop(context);
                    _startEdit(message.id, message.content);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.content_copy),
                title: Text(AppLocalizations.of(context).translate('copy')),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        ).translate('copied_to_clipboard'),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              if (message.senderId == viewModel.currentUserId &&
                  !message.recalled)
                ListTile(
                  leading: const Icon(Icons.undo, color: Colors.orange),
                  title: Text(
                    AppLocalizations.of(context).translate('recall_message'),
                    style: TextStyle(color: Colors.orange),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showRecallConfirmation(message);
                  },
                ),
              if (message.senderId == viewModel.currentUserId)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    AppLocalizations.of(context).translate('delete'),
                    style: TextStyle(color: Colors.red),
                  ),
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
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context).translate('recall_message_question'),
            ),
            content: Text(
              AppLocalizations.of(context).translate('recall_message_warning'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).translate('cancel')),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Recall message
                  _viewModel.recallMessage(message.id);
                },
                child: Text(
                  AppLocalizations.of(context).translate('recall'),
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(Message message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context).translate('delete_message_question'),
            ),
            content: Text(
              AppLocalizations.of(context).translate('delete_message_warning'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).translate('cancel').toUpperCase(),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Delete message
                  _viewModel.deleteMessage(message.id);
                },
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).translate('delete').toUpperCase(),
                  style: TextStyle(color: Colors.red),
                ),
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
          // Lấy trạng thái online/offline và last seen từ ViewModel
          final isOnline = _viewModel.isRecipientOnline;
          final lastSeen = _viewModel.recipientLastSeen;
          final statusText =
              isOnline
                  ? 'Active now'
                  : (lastSeen != null
                      ? _viewModel.formatLastSeen(lastSeen)
                      : 'Offline');
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
                title:
                    _isLoadingChatInfo
                        ? const Text('Loading...')
                        : _chatInfoError != null
                        ? const Text('Chat')
                        : Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.grey.shade300,
                                  child:
                                    (recipientAvatar != null && recipientAvatar!.isNotEmpty)
                                      ? ClipOval(
                                          child: Image.network(
                                            UrlTransformer.transformAvatarUrl(recipientAvatar!),
                                            width: 36,
                                            height: 36,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Text(
                                          recipientName.isNotEmpty
                                              ? recipientName[0].toUpperCase()
                                              : "?",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                                if (isOnline)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              Theme.of(
                                                context,
                                              ).scaffoldBackgroundColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
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
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              isOnline
                                                  ? Colors.green
                                                  : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              isOnline
                                                  ? Colors.green
                                                  : Theme.of(context).hintColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
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
              body:
                  _isLoadingChatInfo
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
                                      backgroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      onPressed: _scrollToBottom,
                                      child: const Icon(
                                        Icons.arrow_downward,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Date indicator (today, yesterday, etc)
                          if (viewModel.showDateIndicator)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12,
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surface.withValues(alpha: 0.7),
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
                                _formatDateIndicator(
                                  viewModel.currentDateIndicator,
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(179),
                                ),
                              ),
                            ),

                          // Typing indicator
                          if (viewModel.isTyping)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                bottom: 8,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '$recipientName is typing',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  _buildTypingIndicator(),
                                ],
                              ),
                            ),

                          // Typing indicator với tên người typing
                          if (viewModel.isOtherUserTyping)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline.withAlpha(100),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildTypingIndicator(),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${viewModel.typingUserName ?? 'Someone'} is typing...',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Pending media preview
                          if (viewModel.pendingMedia != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  if (viewModel.pendingMediaType == 'image')
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(viewModel.pendingMedia!.path),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  if (viewModel.pendingMediaType == 'video')
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            'assets/images/video_placeholder.png',
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                      ],
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => viewModel.sendPendingMedia(
                                            widget.chatId,
                                          ),
                                          icon: const Icon(Icons.send),
                                          label: const Text('Send'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.primary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                          onPressed: viewModel.clearPendingMedia,
                                          tooltip: 'Remove',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                                final replyMessageId =
                                    _isReplying ? _replyingToMessageId : null;
                                final replyToSender =
                                    _isReplying ? _replyingToSender : null;
                                debugPrint(
                                  'ChatDetailView: Sending message with reply to: $replyMessageId',
                                );

                                viewModel.sendMessage(
                                  chatId: widget.chatId,
                                  message: message,
                                  replyToMessageId: replyMessageId,
                                  replyToSender: replyToSender,
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
                            onTypingChanged: (isTyping) {
                              // Gửi typing indicator qua ViewModel
                              viewModel.setUserTyping(isTyping);
                            },
                            aiEditFlow: _aiEditFlow,
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
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation by sending a message',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      // +1 để có chỗ cho loading indicator khi load more
      itemCount: viewModel.messages.length + (viewModel.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Hiển thị loading indicator ở đầu danh sách (cuối cùng vì reverse=true)
        if (index == viewModel.messages.length) {
          return _buildLoadMoreIndicator();
        }

        final message = viewModel.messages[index];

        // Xác định tin nhắn gửi gần nhất của mình (isMe)
        bool isLatestSentMessage = false;
        if (message.senderId == viewModel.currentUserId) {
          // Tìm index đầu tiên (reverse=true, index 0 là mới nhất)
          for (int i = 0; i < viewModel.messages.length; i++) {
            final m = viewModel.messages[i];
            if (m.senderId == viewModel.currentUserId) {
              if (i == index) isLatestSentMessage = true;
              break;
            }
          }
        }

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
          onTapRepliedMessage:
              message.replyToMessageId != null
                  ? () => viewModel.scrollToMessage(message.replyToMessageId!)
                  : null,
          onSwipeReply:
              () => _startReplyWithId(
                message.id,
                message.content,
                message.senderName,
              ),
          mediaUrl: message.mediaUrl,
          fileInfo: message.fileInfo,
          recalled: message.recalled,
          isRead: message.isRead,
          readAt: message.readAt,
          isLatestSentMessage: isLatestSentMessage, // truyền biến mới
        );
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading more messages...',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return SizedBox(
      width: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(180),
                  shape: BoxShape.circle,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleY(
                begin: 0.3,
                end: 1.0,
                duration: const Duration(milliseconds: 800),
                delay: Duration(milliseconds: (index * 200)),
                curve: Curves.elasticOut,
              )
              .then()
              .scaleY(
                begin: 1.0,
                end: 0.3,
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticIn,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                title: Text(AppLocalizations.of(context).translate('search')),
                onTap: () {
                  Navigator.pop(context);
                  // Search implementation
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(
                  AppLocalizations.of(context).translate('mute_notifications'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Mute implementation
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(
                  AppLocalizations.of(
                    context,
                  ).translate('view_media_files_links'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // View media implementation
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  AppLocalizations.of(context).translate('delete_chat'),
                  style: TextStyle(color: Colors.red),
                ),
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
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context).translate('delete_chat_question'),
            ),
            content: Text(
              AppLocalizations.of(context).translate('delete_chat_warning'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).translate('cancel').toUpperCase(),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Return to chat list
                  // Delete chat implementation
                  // _viewModel.deleteChat(widget.chatId);
                },
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).translate('delete').toUpperCase(),
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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

              // Second row with audio and video recording
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAttachmentOption(
                      icon: Icons.mic,
                      color: Colors.orange,
                      label: 'Audio',
                      onTap: () {
                        Navigator.pop(context);
                        _recordAudio();
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.videocam,
                      color: Colors.indigo,
                      label: 'Video',
                      onTap: () {
                        Navigator.pop(context);
                        _recordVideo();
                      },
                    ),
                    // Empty spaces to maintain layout
                    const SizedBox(width: 60),
                    const SizedBox(width: 60),
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
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
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

  void _recordAudio() {
    // Show recording dialog and record audio
    _showAudioRecordingDialog();
  }

  void _recordVideo() {
    // Show recording dialog and record video
    _showVideoRecordingDialog();
  }

  void _showAudioRecordingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.mic, color: Colors.orange),
                SizedBox(width: 8),
                Text('Recording Audio'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.radio_button_checked,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text('Recording voice message...'),
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _viewModel.recordAndSendAudio(widget.chatId);
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  void _showVideoRecordingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.videocam, color: Colors.indigo),
                SizedBox(width: 8),
                Text('Recording Video'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.fiber_manual_record,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text('Recording video message...'),
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _viewModel.recordAndSendVideo(widget.chatId);
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  Widget _buildPinnedMessagesSection(ChatDetailViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
    _viewModel.removeListener(
      _onViewModelChanged,
    ); // Remove listener trước khi dispose
    _viewModel.dispose(); // Dispose viewModel
    super.dispose();
  }
}
