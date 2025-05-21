// lib/presentation/auth/login/login_view.dart

import 'package:flutter/material.dart';
import '../../../core/constants/asset_path.dart';
import '../../../config/theme/app_colors.dart';
import 'widgets/login_form.dart';
import 'widgets/social_login_buttons.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  LinearGradient _getBackgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
    final theme = Theme.of(context);
    return Scaffold(
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
                  Hero(
                    tag: "amoura_logo",
                    child: Image.asset(
                      AssetPath.logo,
                      width: 70,
                      height: 70,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    "Sign in to find your love",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  LoginForm(
                    onLogin: (account, password) {
                      // Gọi ViewModel xử lý login hoặc show loading
                    },
                  ),
                  const SizedBox(height: 18),
                  SocialLoginButtons(
                    onGoogle: () {
                      // Xử lý login Google (tích hợp OAuth sau)
                    },
                    onFacebook: () {
                      // Xử lý login Facebook (tích hợp OAuth sau)
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: theme.textTheme.bodyMedium,
                      ),
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