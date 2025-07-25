import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4.0,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: widget.onAttachmentTap,
                  splashRadius: 20.0,
                ),

                // Camera button
                IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: widget.onCameraTap,
                  splashRadius: 20.0,
                ),

                // Text input field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Row(
                      children: [
                        // Emoji button
                        IconButton(
                          icon: Icon(
                            _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
                            color: theme.iconTheme.color,
                          ),
                          onPressed: _toggleEmojiPicker,
                          splashRadius: 20.0,
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
                                vertical: 10.0,
                                horizontal: 8.0,
                              ),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 5,
                            minLines: 1,
                            onSubmitted: (_) => _handleSend(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8.0),

                // Send button
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: _showSendButton
                      ? IconButton(
                          key: const ValueKey('send_button'),
                          icon: Icon(
                            Icons.send,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: _handleSend,
                          splashRadius: 20.0,
                        )
                      : IconButton(
                          key: const ValueKey('mic_button'),
                          icon: Icon(
                            Icons.mic,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () {
                            // Voice recording functionality would go here
                          },
                          splashRadius: 20.0,
                        ),
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
}

