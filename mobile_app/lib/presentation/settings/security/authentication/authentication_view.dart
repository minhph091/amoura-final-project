import 'package:flutter/material.dart';
import '../../../../config/language/app_localizations.dart';
import '../../widgets/settings_section_title.dart';
import '../../widgets/settings_tile.dart';
import 'widgets/change_password_view.dart';
import 'widgets/change_email_view.dart';
import 'widgets/change_phone_view.dart';

class AuthenticationView extends StatelessWidget {
  const AuthenticationView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionTitle(
          title: localizations.translate('password_and_authentication'),
        ),
        SettingsTile(
          icon: Icons.key,
          title: localizations.translate('change_password'),
          onTap:
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordView()),
              ),
        ),
        SettingsTile(
          icon: Icons.email_outlined,
          title: localizations.translate('change_email'),
          onTap:
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangeEmailView()),
              ),
        ),
        SettingsTile(
          icon: Icons.phone_android,
          title: localizations.translate('change_phone'),
          onTap:
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePhoneView()),
              ),
        ),
      ],
    );
  }
}
