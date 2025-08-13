import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function() onAttachmentTap;
  final Function() onCameraTap;
  final Function() onLikeTap;
  final bool isReplying;
  final String? replyingTo;
  final Function() onCancelReply;
  final bool isEditing;
  final String? editingText;
  final Function() onCancelEdit;
  final FocusNode? focusNode;
  final Function(bool)? onTypingChanged; // Callback cho typing indicator
  final Future<String?> Function(String original)? aiEditFlow; // Callback AI chỉnh sửa

  const MessageInput({
    super.key,
    required this.onSendMessage,
    required this.onAttachmentTap,
    required this.onCameraTap,
    required this.onLikeTap,
    this.isReplying = false,
    this.replyingTo,
    required this.onCancelReply,
    this.isEditing = false,
    this.editingText,
    required this.onCancelEdit,
    this.focusNode,
    this.onTypingChanged,
    this.aiEditFlow,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSendButton = false;
  bool _showEmojiPicker = false;
  bool _isTyping = false; // Track typing state
  bool _isAiLoading = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    
    // Listen to focus changes để stop typing khi lose focus
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isTyping) {
        _isTyping = false;
        widget.onTypingChanged?.call(false);
      }
    });

    // Initialize with editing text if provided
    if (widget.isEditing && widget.editingText != null) {
      _messageController.text = widget.editingText!;
      _showSendButton = true;

      // Position cursor at end of text when editing
      _focusNode.requestFocus();
      _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );
    }
  }

  @override
  void didUpdateWidget(MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update text field when editing mode changes
    if (widget.isEditing && !oldWidget.isEditing && widget.editingText != null) {
      _messageController.text = widget.editingText!;
      _showSendButton = true;

      // Position cursor at end of text when editing
      _focusNode.requestFocus();
      _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );
    }
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    final shouldShowTyping = hasText && _focusNode.hasFocus;
    
    setState(() {
      _showSendButton = hasText;
    });
    
    // Send typing indicator khi có text và focus
    if (shouldShowTyping != _isTyping) {
      _isTyping = shouldShowTyping;
      widget.onTypingChanged?.call(_isTyping);
    }
  }

  void _handleSend() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      // Stop typing indicator trước khi send
      if (_isTyping) {
        _isTyping = false;
        widget.onTypingChanged?.call(false);
      }
      
      widget.onSendMessage(message);
      _messageController.clear();
      setState(() {
        _showSendButton = false;
        _showEmojiPicker = false;
      });
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });

    // If showing emoji picker, dismiss keyboard; if hiding, focus on text field
    if (_showEmojiPicker) {
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  Future<void> _handleAiEdit() async {
    final text = _messageController.text.trim();
    if (widget.aiEditFlow == null) return;

    setState(() { _isAiLoading = true; });

    try {
      // Mở AI composer (có thể không có sẵn text). Composer sẽ xử lý xác nhận ngay trong sheet
      final edited = await widget.aiEditFlow!.call(text);
      if (edited != null && edited.trim().isNotEmpty) {
        _messageController.text = edited.trim();
        _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length),
        );
        setState(() { _showSendButton = true; });
      }
    } finally {
      if (mounted) setState(() { _isAiLoading = false; });
    }
  }

  void _showAiEditConfirmation(String original, String edited) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  children: [
                    const Icon(Icons.auto_fix_high, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Tin nhắn đã được chỉnh sửa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Original text
                const Text(
                  'Tin nhắn gốc:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    original,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Edited text
                const Text(
                  'Tin nhắn đã chỉnh sửa:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    edited,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          // "Sửa lại" - gọi lại aiEditFlow với tone hiện tại (được view quản lý), tránh lặp lại
                          Navigator.pop(context);
                          final current = _messageController.text.trim();
                          final editedAgain = await widget.aiEditFlow?.call(current.isEmpty ? original : current);
                          if (!mounted) return;
                          if (editedAgain != null && editedAgain.trim().isNotEmpty) {
                            _showAiEditConfirmation(original, editedAgain.trim());
                          }
                        },
                        child: const Text('Sửa lại'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _messageController.text = edited;
                          _messageController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _messageController.text.length),
                          );
                          setState(() { _showSendButton = true; });
                        },
                        child: const Text('Đồng ý'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildReplyOrEditBanner() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 6.0, left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        gradient: widget.isEditing 
            ? LinearGradient(
                colors: [Colors.amber.shade50, Colors.amber.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [const Color(0xFFFF6B9D).withValues(alpha: 0.1), Colors.pink.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: widget.isEditing 
              ? Colors.amber.withValues(alpha: 0.3)
              : const Color(0xFFFF6B9D).withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Reply/Edit indicator line
          Container(
            width: 3.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: widget.isEditing ? Colors.amber : const Color(0xFFFF6B9D),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 12.0),
          
          // Reply icon
          Icon(
            widget.isEditing ? Icons.edit : Icons.reply,
            size: 18.0,
            color: widget.isEditing ? Colors.amber.shade700 : const Color(0xFFFF6B9D),
          ),
          const SizedBox(width: 8.0),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isEditing ? '✏️ Editing message' : '💬 Replying to message',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.0,
                    color: widget.isEditing ? Colors.amber.shade700 : const Color(0xFFFF6B9D),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    widget.isEditing
                        ? widget.editingText ?? ''
                        : widget.replyingTo ?? '',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.grey.shade600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Close button  
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18.0,
                color: Colors.grey.shade600,
              ),
              onPressed: widget.isEditing
                  ? widget.onCancelEdit
                  : widget.onCancelReply,
              splashRadius: 16.0,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    ).animate().slideY(
      begin: -0.5,
      end: 0.0,
      duration: 300.ms,
      curve: Curves.easeOutBack,
    ).fadeIn(duration: 200.ms);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Reply/Edit preview if active
        if (widget.isReplying || widget.isEditing)
          _buildReplyOrEditBanner(),

        // Main input bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          color: theme.scaffoldBackgroundColor, // bỏ khung bao tổng, dùng nền phẳng
          child: SafeArea(
            child: Row(
              children: [
                // Attachment button
                _buildCircleIcon(
                  context,
                  icon: PhosphorIcons.paperclip(),
                  onTap: widget.onAttachmentTap,
                ),

                // Camera button
                const SizedBox(width: 4),
                _buildCircleIcon(
                  context,
                  icon: PhosphorIcons.camera(),
                  onTap: widget.onCameraTap,
                ),

                // Text input field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Emoji button
                        _buildInnerIcon(
                          context,
                          icon: _showEmojiPicker ? PhosphorIcons.keyboard() : PhosphorIcons.smiley(),
                          onTap: _toggleEmojiPicker,
                        ),

                        // AI edit button
                        if (widget.aiEditFlow != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: _isAiLoading
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                    ),
                                  )
                                : _buildInnerIcon(
                                    context,
                                    icon: PhosphorIcons.magicWand(),
                                    onTap: _handleAiEdit,
                                    tooltip: 'AI edit',
                                  ),
                          ),

                        // Text field
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            focusNode: _focusNode,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 8.0,
                              ),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 4,
                            minLines: 1,
                            onSubmitted: (_) => _handleSend(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 6.0),

                // Send button
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: _showSendButton
                      ? _buildCircleIcon(context, icon: PhosphorIcons.paperPlaneRight(), onTap: _handleSend)
                      : _buildCircleIcon(context, icon: PhosphorIcons.microphone(), onTap: () {}),
                ),
              ],
            ),
          ),
        ),

        // Emoji picker would be implemented here
        // You can use packages like emoji_picker_flutter
        if (_showEmojiPicker)
          Container(
            height: 250,
            color: theme.scaffoldBackgroundColor,
            child: const Center(
              child: Text('Emoji Picker Placeholder'),
            ),
          ).animate().slideY(
            begin: 1.0,
            end: 0.0,
            duration: 200.ms,
            curve: Curves.easeOutQuad,
          ),
      ],
    );
  }

  // Helpers for consistent icons
  Widget _buildCircleIcon(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Icon(icon, size: 18, color: theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildInnerIcon(BuildContext context, {required IconData icon, required VoidCallback onTap, String? tooltip}) {
    final theme = Theme.of(context);
    final btn = Icon(icon, color: theme.iconTheme.color, size: 18);
    return IconButton(
      icon: btn,
      tooltip: tooltip,
      onPressed: onTap,
      splashRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}

