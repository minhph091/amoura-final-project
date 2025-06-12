import 'package:flutter/material.dart';
import '../../widgets/settings_section_title.dart';
import '../../widgets/settings_tile.dart';
import 'authentication_viewmodel.dart';
import 'widgets/change_password_view.dart';
import 'widgets/change_email_view.dart';

class AuthenticationView extends StatelessWidget {
  const AuthenticationView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = AuthenticationViewModel();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
      ],
    );
  }
}