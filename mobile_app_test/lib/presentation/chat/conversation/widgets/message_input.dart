import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function() onAttachmentTap;
  final Function() onCameraTap;
  final bool isReplying;
  final String? replyingTo;
  final Function() onCancelReply;
  final bool isEditing;
  final String? editingText;
  final Function() onCancelEdit;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    required this.onAttachmentTap,
    required this.onCameraTap,
    this.isReplying = false,
    this.replyingTo,
    required this.onCancelReply,
    this.isEditing = false,
    this.editingText,
    required this.onCancelEdit,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageController = TextEditingController();
  bool _showSendButton = false;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);

    // Initialize with editing text if provided
    if (widget.isEditing && widget.editingText != null) {
      _messageController.text = widget.editingText!;
      _showSendButton = true;
    }
  }

  @override
  void didUpdateWidget(MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update text field when editing mode changes
    if (widget.isEditing && !oldWidget.isEditing && widget.editingText != null) {
      _messageController.text = widget.editingText!;
      _showSendButton = true;
    }
  }

  void _onTextChanged() {
    setState(() {
      _showSendButton = _messageController.text.trim().isNotEmpty;
    });
  }

  void _handleSend() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
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
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Reply/Edit preview if active
        if (widget.isReplying || widget.isEditing)
          _buildReplyOrEditBanner(),

        // Main input bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -1),
                blurRadius: 3,
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: widget.onAttachmentTap,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),

                // Camera button
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: widget.onCameraTap,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),

                // Text input field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Row(
                      children: [
                        // Emoji toggle button
                        IconButton(
                          icon: Icon(
                            _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined,
                            size: 22,
                          ),
                          onPressed: _toggleEmojiPicker,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),

                        // Text field
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: widget.isEditing
                                  ? 'Edit message...'
                                  : widget.isReplying
                                  ? 'Reply to message...'
                                  : 'Type a message...',
                              hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            minLines: 1,
                          ),
                        ),

                        // Send button (conditionally shown)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: _showSendButton
                              ? IconButton(
                            key: const ValueKey('send'),
                            icon: Icon(
                              widget.isEditing ? Icons.check : Icons.send,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: _handleSend,
                          )
                              : IconButton(
                            key: const ValueKey('mic'),
                            icon: Icon(
                              Icons.mic_none_rounded,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              // Voice recording functionality here
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Emoji picker goes here (would need a package like emoji_picker_flutter)
        if (_showEmojiPicker)
          Container(
            height: 250,
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Text(
                'Emoji Picker',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ).animate().slideY(begin: 1, end: 0, duration: 200.ms),
      ],
    );
  }

  Widget _buildReplyOrEditBanner() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Row(
        children: [
          Icon(
            widget.isEditing ? Icons.edit : Icons.reply,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isEditing ? 'Editing Message' : 'Replying to',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.isEditing ? widget.editingText ?? '' : widget.replyingTo ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: widget.isEditing ? widget.onCancelEdit : widget.onCancelReply,
            splashRadius: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 200.ms);
  }
}
