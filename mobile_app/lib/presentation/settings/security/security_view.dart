import 'package:flutter/material.dart';
import '../../../config/language/app_localizations.dart';
import '../../shared/widgets/app_gradient_background.dart';
import 'authentication/authentication_view.dart';
import 'account_management/account_management_view.dart';

class SecurityView extends StatelessWidget {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    debugPrint('Current theme is dark: $isDark');

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(localizations.translate('account_security_title')),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const AuthenticationView(),
            const AccountManagementView(),
            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }
}
