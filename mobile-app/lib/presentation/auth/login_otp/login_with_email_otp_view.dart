// lib/presentation/auth/login_otp/login_with_email_otp_view.dart

import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import 'widgets/email_input_form.dart';

class LoginWithEmailOtpView extends StatelessWidget {
  const LoginWithEmailOtpView({super.key});

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
    return Scaffold(
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
                  // Logo + app name giống login
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
                    "Sign in with Email OTP",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your email to receive a one-time login code.",
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: EmailInputForm(
                      onSend: (email) => Navigator.of(context).pushNamed(
                        '/login-email-otp-verify',
                        arguments: {'email': email},
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).maybePop();
                        },
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
    );
  }
}