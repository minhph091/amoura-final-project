import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_gradient_background.dart';
import '../../widgets/change_password_form_wigdet.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    print('Current theme is dark: $isDark');

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Change Password'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const ChangePasswordFormWidget(),
      ),
    );
  }
}