import 'package:flutter/material.dart';
import '../../../shared/dialogs/confirm_dialog.dart';
import '../../widgets/settings_section_title.dart';
import '../../widgets/settings_tile.dart';
import 'login_sessions_viewmodel.dart';

class LoginSessionsView extends StatelessWidget {
  const LoginSessionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = LoginSessionsViewModel();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionTitle(title: 'Login Sessions'),
        SettingsTile(
          icon: Icons.devices_outlined,
          title: 'Active Sessions',
          subtitle: 'See all devices where you\'re logged in',
          onTap: () {
            // Show active sessions
          },
        ),
        SettingsTile(
          icon: Icons.logout_outlined,
          title: 'Sign Out From All Devices',
          onTap: () async {
            final result = await showConfirmDialog(
              context: context,
              title: 'Sign Out Everywhere',
              content: 'Are you sure you want to sign out from all devices?',
              confirmText: 'Yes, Sign Out',
              cancelText: 'Cancel',
              icon: Icons.logout_outlined,
              iconColor: colorScheme.error,
            );

            if (result == true) {
              // Implement sign out from all devices
            }
          },
        ),
      ],
    );
  }
}