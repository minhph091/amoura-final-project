import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/language/app_localizations.dart';
import '../../shared/widgets/app_gradient_background.dart';
import 'notification_settings_viewmodel.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  bool _hasChanges = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return ChangeNotifierProvider(
      create: (_) => NotificationSettingsViewModel(),
      child: Consumer<NotificationSettingsViewModel>(
        builder: (context, viewModel, _) {
          return AppGradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(localizations.translate('notification_settings')),
                centerTitle: true,
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        _buildSelectAllSection(viewModel, context),
                        const SizedBox(height: 24),
                        _buildNotificationSection(
                          context: context,
                          title: localizations.translate(
                            'system_notifications',
                          ),
                          description: localizations.translate(
                            'get_notified_important_updates',
                          ),
                          isEnabled: viewModel.systemNotifications,
                          onChanged: (value) {
                            viewModel.setSystemNotifications(value ?? false);
                            setState(() => _hasChanges = true);
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildNotificationSection(
                          context: context,
                          title: localizations.translate('like_notifications'),
                          description: localizations.translate(
                            'get_notified_likes',
                          ),
                          isEnabled: viewModel.likeNotifications,
                          onChanged: (value) {
                            viewModel.setLikeNotifications(value ?? false);
                            setState(() => _hasChanges = true);
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildNotificationSection(
                          context: context,
                          title: localizations.translate(
                            'message_notifications',
                          ),
                          description: localizations.translate(
                            'get_notified_messages',
                          ),
                          isEnabled: viewModel.messageNotifications,
                          onChanged: (value) {
                            viewModel.setMessageNotifications(value ?? false);
                            setState(() => _hasChanges = true);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_hasChanges)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            viewModel.saveSettings();
                            setState(() => _hasChanges = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('notification_settings_saved'),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'SAVE CHANGES',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectAllSection(
    NotificationSettingsViewModel viewModel,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final allSelected = viewModel.allNotificationsEnabled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                localizations.translate('all_notification_types'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            localizations.translate('enable_disable_all_notifications'),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              viewModel.setAllNotifications(!allSelected);
              setState(() => _hasChanges = true);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.translate('enable_all_notification_types'),
                    style: theme.textTheme.bodyLarge,
                  ),
                  Switch(
                    value: allSelected,
                    onChanged: (value) {
                      viewModel.setAllNotifications(value);
                      setState(() => _hasChanges = true);
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection({
    required BuildContext context,
    required String title,
    required String description,
    required bool isEnabled,
    required ValueChanged<bool?> onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getIconForTitle(title), color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onChanged(!isEnabled),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Enable $title', style: theme.textTheme.bodyMedium),
                  Switch(
                    value: isEnabled,
                    onChanged: onChanged,
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'System Notifications':
        return Icons.info_outline;
      case 'Like Notifications':
        return Icons.favorite_border;
      case 'Message Notifications':
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications_none;
    }
  }
}
