// lib/presentation/auth/login_otp/login_otp_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/constants/asset_path.dart';
import 'widgets/email_input_form.dart';
import 'login_otp_viewmodel.dart';

class LoginOtpView extends StatelessWidget {
  const LoginOtpView({super.key});

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
    return ChangeNotifierProvider(
      create: (_) => LoginOtpViewModel(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: _getBackgroundGradient(context),
          ),
          width: double.infinity,
          height: double.infinity,
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
                      "Sign in with Email OTP",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter your email to receive a one-time login code.",
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const EmailInputForm(),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.grey),
                        const SizedBox(width: 5),
                        TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Text("Back to sign in"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}