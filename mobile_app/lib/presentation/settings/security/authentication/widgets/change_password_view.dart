import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amoura/data/repositories/user_repository.dart';
import '../../../../../config/language/app_localizations.dart';
import '../../../../shared/widgets/app_gradient_background.dart';
import '../../widgets/change_password_form_wigdet.dart';
import 'change_password_viewmodel.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    debugPrint('Current theme is dark: $isDark');
    final userRepository = Provider.of<UserRepository>(context, listen: false);
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(localizations.translate('change_password')),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ChangeNotifierProvider(
          create: (_) => ChangePasswordViewModel(userRepository: userRepository),
          child: const ChangePasswordFormWidget(),
        ),
      ),
    );
  }
}
