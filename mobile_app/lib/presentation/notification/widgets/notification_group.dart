import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../config/language/app_localizations.dart';
import '../notification_viewmodel.dart';
import 'notification_item.dart';

class NotificationGroup extends StatelessWidget {
  final String title;
  final List<UINotificationModel> notifications;
  final Function(UINotificationModel) onNotificationTap;
  final Function(UINotificationModel) onNotificationDismiss;
  final VoidCallback? onMarkAllAsRead;
  final VoidCallback? onDeleteAll;

  const NotificationGroup({
    super.key,
    required this.title,
    required this.notifications,
    required this.onNotificationTap,
    required this.onNotificationDismiss,
    this.onMarkAllAsRead,
    this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    try {
      if (notifications.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                  ),
                ),
                // Action buttons
                if (notifications.isNotEmpty)
                  Row(
                    children: [
                      // Mark all as read button
                      if (onMarkAllAsRead != null &&
                          notifications.any((n) => !n.isRead))
                        GestureDetector(
                          onTap: onMarkAllAsRead,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              ).translate('mark_all_read'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      // Delete all button
                      if (onDeleteAll != null)
                        GestureDetector(
                          onTap: () => _showDeleteAllConfirmation(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              ).translate('delete_all'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),

          // Group notifications
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Container(
                  margin:
                      index == 0
                          ? EdgeInsets.zero
                          : const EdgeInsets.only(top: 4),
                  child: GestureDetector(
                    onLongPress:
                        () => _showDeleteConfirmation(context, notification),
                    child: NotificationItem(
                      notification: notification,
                      onTap: () => onNotificationTap(notification),
                      onDismiss: () => onNotificationDismiss(notification),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      );
    } catch (e) {
      debugPrint('NotificationGroup: Error building widget: $e');
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            'Error loading notification group',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    UINotificationModel notification,
  ) {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Column(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context).translate('delete_notification'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                AppLocalizations.of(
                  context,
                ).translate('delete_notification_message'),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            actions: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: Text(AppLocalizations.of(context).translate('cancel')),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onNotificationDismiss(notification);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(AppLocalizations.of(context).translate('delete')),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('NotificationGroup: Error showing delete confirmation: $e');
    }
  }

  void _showDeleteAllConfirmation(BuildContext context) {
    try {
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.25),
        builder: (context) {
          final pink = const Color(0xFFFF6B9D);
          final orange = const Color(0xFFFF8E9E);
          return Dialog(
            backgroundColor: Colors.white.withOpacity(0.98),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [pink, orange]),
                      boxShadow: [
                        BoxShadow(
                          color: pink.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppLocalizations.of(context).translate('delete_all_notifications'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)
                        .translate('delete_all_notifications_message')
                        .replaceAll('{count}', notifications.length.toString()),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: pink,
                            side: BorderSide(color: pink, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          child: Text(AppLocalizations.of(context).translate('cancel')),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onDeleteAll?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            backgroundColor: Colors.transparent, // Không có màu nền mặc định
                            shadowColor: Colors.transparent, // Không shadow
                            side: BorderSide.none, // Không viền
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [pink, orange]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              constraints: const BoxConstraints(minHeight: 16),
                              child: Text(AppLocalizations.of(context).translate('delete_all')),
                            ),
                          ),
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
    } catch (e) {
      debugPrint('NotificationGroup: Error showing delete all confirmation: $e');
    }
  }
}
