// lib/presentation/auth/login/login_view.dart

import 'package:flutter/material.dart';
import 'widgets/login_form.dart';
import 'widgets/social_login_buttons.dart';
import '../../../config/theme/app_colors.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  LinearGradient _getBackgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Bạn có thể tùy chỉnh các màu này theo AppColors
    return isDark
        ? LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.darkBackground,
        AppColors.darkSecondary.withValues(alpha: 0.90),
        AppColors.darkPrimary.withValues(alpha: 0.82),
      ],
    )
        : LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.background,
        AppColors.primary.withValues(alpha: 0.13),
        AppColors.secondary.withValues(alpha: 0.06),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // KHÔNG dùng backgroundColor ở đây!
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: _getBackgroundGradient(context),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo + app name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/light_amoura.png',
                        width: 66,
                        height: 66,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    "Sign in to find your love",
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Login Form
                  const LoginForm(),
                  const SizedBox(height: 18),
                  // Social login buttons
                  const SocialLoginButtons(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?",
                          style: Theme.of(context).textTheme.bodyMedium),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/register');
                        },
                        child: const Text("Register now"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}