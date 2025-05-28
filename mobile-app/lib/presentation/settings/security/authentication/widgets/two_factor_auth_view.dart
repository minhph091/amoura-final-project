import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_gradient_background.dart';

class TwoFactorAuthView extends StatelessWidget {
  const TwoFactorAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    print('Current theme is dark: $isDark');

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Two-Factor Authentication'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Two-Factor Authentication Content'),
        ),
      ),
    );
  }
}