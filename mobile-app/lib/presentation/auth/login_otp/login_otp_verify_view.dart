// lib/presentation/auth/login_otp/login_otp_verify_view.dart

import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/constants/asset_path.dart';
import '../../shared/widgets/otp_input_form.dart';

class LoginOtpVerifyView extends StatelessWidget {
  final String email;
  const LoginOtpVerifyView({super.key, required this.email});

  LinearGradient _getBackgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.darkBackground,
        AppColors.darkSecondary.withValues(alpha: 0.85),
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
                    "OTP Verification",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Enter the 6-digit code sent to your email.",
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      email,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  OtpInputForm(
                    otpLength: 6,
                    onSubmit: (otp) {
                      // Xử lý xác thực OTP: Để backend xử lý
                    },
                    resendAvailable: true,
                    onResend: () {
                      // Để backend xử lý gửi lại OTP
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Didn't receive the code? Check your spam or resend.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
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