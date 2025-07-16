import 'package:flutter/material.dart';
import '../../../shared/dialogs/confirm_dialog.dart';
import '../../widgets/settings_divider.dart';
import '../../widgets/settings_section_title.dart';
import '../../widgets/settings_tile.dart';
import '../authentication/widgets/change_password_view.dart';
import '../authentication/widgets/change_email_view.dart';
import '../account_management/account_management_view.dart';
import '../../../../config/language/app_localizations.dart';

class SecurityBodyWidget extends StatelessWidget {
  const SecurityBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SettingsSectionTitle(
            title: AppLocalizations.of(
              context,
            ).translate('password_authentication'),
          ),
          SettingsTile(
            icon: Icons.key,
            title: AppLocalizations.of(context).translate('change_password'),
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChangePasswordView()),
                ),
          ),
          SettingsTile(
            icon: Icons.email_outlined,
            title: AppLocalizations.of(context).translate('change_email'),
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChangeEmailView()),
                ),
          ),
          const SettingsDivider(),

          SettingsSectionTitle(
            title: AppLocalizations.of(context).translate('account_management'),
          ),
          SettingsTile(
            icon: Icons.lock_person_outlined,
            title: AppLocalizations.of(context).translate('deactivate_account'),
            subtitle: AppLocalizations.of(
              context,
            ).translate('temporarily_disable_account'),
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AccountManagementView(),
                  ),
                ),
          ),
          SettingsTile(
            icon: Icons.delete_forever,
            title: AppLocalizations.of(
              context,
            ).translate('delete_account_permanently'),
            subtitle: AppLocalizations.of(
              context,
            ).translate('action_cannot_undone'),
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: () async {
              final result = await showConfirmDialog(
                context: context,
                title: AppLocalizations.of(context).translate('delete_account'),
                content: AppLocalizations.of(
                  context,
                ).translate('delete_account_info'),
                confirmText: AppLocalizations.of(
                  context,
                ).translate('delete_permanently'),
                cancelText: AppLocalizations.of(context).translate('cancel'),
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
