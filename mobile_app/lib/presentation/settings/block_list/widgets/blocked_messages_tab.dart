import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/language/app_localizations.dart';
import '../../../../domain/models/settings/blocked_message.dart';
import '../../../../infrastructure/services/blocking_service.dart';
import 'blocked_message_item.dart';

class BlockedMessagesTab extends StatelessWidget {
  const BlockedMessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final blockingService = context.watch<BlockingService>();
    final blockedMessages = blockingService.blockedMessages;

    if (blockingService.isLoadingMessages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (blockedMessages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No blocked messages',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: blockedMessages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final blockedMessage = blockedMessages[index];
        return BlockedMessageItem(
          blockedMessage: blockedMessage,
          onTap: () => _navigateToChat(context, blockedMessage),
          onUnblock: () => _handleUnblock(context, blockedMessage.id),
        );
      },
    );
  }

  void _navigateToChat(BuildContext context, BlockedMessage blockedMessage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _BlockedChatView(blockedMessage: blockedMessage),
      ),
    );
  }

  Future<void> _handleUnblock(BuildContext context, String messageId) async {
    final blockingService = context.read<BlockingService>();
    await blockingService.unblockMessage(messageId);
  }
}

// Blocked chat view with white overlay and "Unblock" button
class _BlockedChatView extends StatelessWidget {
  final BlockedMessage blockedMessage;

  const _BlockedChatView({required this.blockedMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(blockedMessage.userPhotoUrl),
              radius: 16,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  blockedMessage.userName,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  '${blockedMessage.age}, ${blockedMessage.location}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Example chat UI (would be replaced with actual chat)
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Today',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
              _ChatMessageBubble(
                message: blockedMessage.lastMessage,
                time: blockedMessage.timestamp,
                isFromMe: false,
              ),
              _ChatMessageBubble(
                message: 'You have blocked this user',
                time: blockedMessage.timestamp.add(const Duration(minutes: 5)),
                isFromMe: true,
              ),
            ],
          ),

          // White overlay
          Positioned.fill(
            child: Container(
              color: Colors.white.withAlpha(
                179,
              ), // 0.7 opacity converted to alpha
            ),
          ),

          // Unblock button at bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: () => _handleUnblock(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                AppLocalizations.of(context).translate('unblock_message'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUnblock(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context).translate('unblock_message'),
            ),
            content: Text(
              'Do you want to unblock messages from ${blockedMessage.userName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context).translate('cancel')),
              ),
              TextButton(
                onPressed: () {
                  final blockingService = context.read<BlockingService>();
                  blockingService.unblockMessage(blockedMessage.id).then((_) {
                    // Close dialog and return to blocked messages list
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(AppLocalizations.of(context).translate('unblock')),
              ),
            ],
          ),
    );
  }
}

// Simple chat bubble for demonstration
class _ChatMessageBubble extends StatelessWidget {
  final String message;
  final DateTime time;
  final bool isFromMe;

  const _ChatMessageBubble({
    required this.message,
    required this.time,
    required this.isFromMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isFromMe
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(color: isFromMe ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(time),
              style: TextStyle(
                fontSize: 10,
                color: isFromMe ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
