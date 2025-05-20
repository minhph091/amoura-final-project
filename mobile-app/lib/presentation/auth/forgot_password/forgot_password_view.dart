// lib/presentation/auth/forgot_password/forgot_password_form.dart

import 'package:flutter/material.dart';
import 'widgets/forgot_email_form.dart';
import '../../shared/widgets/otp_input_form.dart';
import '../../../config/theme/app_colors.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key, required email}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  bool hasSentEmail = false;
  String? email;

  LinearGradient _getBackgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.darkBackground,
        AppColors.darkSecondary.withOpacity(0.90),
        AppColors.darkPrimary.withOpacity(0.82),
      ],
    )
        : LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.background,
        AppColors.primary.withOpacity(0.13),
        AppColors.secondary.withOpacity(0.06),
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
                    "Forgot Password",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasSentEmail
                        ? "Enter the 6-digit code sent to your email."
                        : "Enter your email to receive a password reset code.",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.95),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (email != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        email!,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: !hasSentEmail
                        ? ForgotEmailForm(
                      key: const ValueKey('email-form'),
                      onSend: (val) => setState(() {
                        email = val;
                        hasSentEmail = true;
                      }),
                    )
                        : OtpInputForm(
                      key: const ValueKey('otp-form'),
                      otpLength: 6,
                      onSubmit: (otp) {
                        // Để backend xử lý xác thực OTP
                      },
                      resendAvailable: true,
                      onResend: () {
                        // Để backend xử lý gửi lại OTP
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (hasSentEmail)
                    TextButton.icon(
                      onPressed: () => setState(() => hasSentEmail = false),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      label: const Text("Back to Email"),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
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