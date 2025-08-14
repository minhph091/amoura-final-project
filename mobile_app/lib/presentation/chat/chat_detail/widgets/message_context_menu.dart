import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../domain/models/message.dart';

class MessageContextMenu extends StatelessWidget {
  final Message message;
  final bool isMyMessage;
  final Function(Message message) onReply;
  final Function(Message message) onDelete;
  final Function(Message message) onPin;
  final Function(Message message) onReport;
  final VoidCallback onClose;

  const MessageContextMenu({
    super.key,
    required this.message,
    required this.isMyMessage,
    required this.onReply,
    required this.onDelete,
    required this.onPin,
    required this.onReport,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAction(
            context,
            Icons.reply,
            'Reply',
            () {
              onClose();
              onReply(message);
            },
          ),
          _buildDivider(),
          _buildAction(
            context,
            Icons.content_copy,
            'Copy',
            () {
              Clipboard.setData(ClipboardData(text: message.content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
              onClose();
            },
          ),
          _buildDivider(),
          _buildAction(
            context,
            Icons.push_pin,
            message.isPinned ? 'Unpin' : 'Pin message',
            () {
              onClose();
              onPin(message);
            },
          ),
          if (isMyMessage) ...[
            _buildDivider(),
            _buildAction(
              context,
              Icons.delete,
              'Delete for me',
              () {
                onClose();
                _showDeleteConfirmation(context);
              },
              textColor: Colors.red,
            ),
          ] else ...[
            _buildDivider(),
            _buildAction(
              context,
              Icons.flag,
              'Report message',
              () {
                onClose();
                onReport(message);
              },
              textColor: Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: textColor ?? AppColors.primary),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message?'),
        content: const Text('This message will be deleted for you only.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(message);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
