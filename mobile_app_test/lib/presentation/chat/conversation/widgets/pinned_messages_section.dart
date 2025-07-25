import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../data/models/chat/message_model.dart';

class PinnedMessagesSection extends StatefulWidget {
  final List<MessageModel> pinnedMessages;
  final Function(MessageModel) onTapPinnedMessage;
  final Function(MessageModel) onUnpinMessage;

  const PinnedMessagesSection({
    super.key,
    required this.pinnedMessages,
    required this.onTapPinnedMessage,
    required this.onUnpinMessage,
  });

  @override
  State<PinnedMessagesSection> createState() => _PinnedMessagesSectionState();
}

class _PinnedMessagesSectionState extends State<PinnedMessagesSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.pinnedMessages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.push_pin, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Pinned Messages (${widget.pinnedMessages.length})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20,
              ),
            ],
          ),
          if (_isExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Column(
                children: widget.pinnedMessages.map((message) => _buildPinnedMessageItem(context, message)).toList(),
              ),
            ).animate().fadeIn(duration: 200.ms),
          if (!_isExpanded && widget.pinnedMessages.isNotEmpty)
            _buildPinnedMessageItem(context, widget.pinnedMessages.first),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.1, end: 0, duration: 300.ms);
  }

  Widget _buildPinnedMessageItem(BuildContext context, MessageModel message) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => widget.onTapPinnedMessage(message),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User ${message.senderId}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.content,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => widget.onUnpinMessage(message),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 18,
            tooltip: 'Unpin message',
          ),
        ],
      ),
    );
  }
}
