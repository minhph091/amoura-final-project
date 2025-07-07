import 'package:flutter/material.dart';
import '../../../shared/dialogs/confirm_dialog.dart';
import '../../widgets/settings_divider.dart';
import '../../widgets/settings_section_title.dart';
import '../../widgets/settings_tile.dart';
import '../authentication/widgets/change_password_view.dart';
import '../authentication/widgets/change_email_view.dart';
import '../account_management/account_management_view.dart';

class SecurityBodyWidget extends StatelessWidget {
  const SecurityBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox.expand(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SettingsSectionTitle(title: 'Password & Authentication'),
          SettingsTile(
            icon: Icons.key,
            title: 'Change Password',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordView())),
          ),
          SettingsTile(
            icon: Icons.email_outlined,
            title: 'Change Email',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangeEmailView())),
          ),
          const SettingsDivider(),

          const SettingsSectionTitle(title: 'Account Management'),
          SettingsTile(
            icon: Icons.lock_person_outlined,
            title: 'Deactivate Account',
            subtitle: 'Temporarily disable your account',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountManagementView())),
          ),
          SettingsTile(
            icon: Icons.delete_forever,
            title: 'Delete Account Permanently',
            subtitle: 'This action cannot be undone',
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: () async {
              final result = await showConfirmDialog(
                context: context,
                title: 'Delete Account',
                content: 'Are you absolutely sure you want to delete your account? This action cannot be undone and all your data will be lost.',
                confirmText: 'Delete Permanently',
                cancelText: 'Cancel',
                icon: Icons.delete_forever,
                iconColor: Colors.red,
              );
              if (result == true) {
                // Implement account deletion (backend logic)
              }
            },
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 200),
        ],
      ),
    );
  }
}