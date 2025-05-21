// lib/presentation/auth/forgot_password/forgot_password_view.dart

import 'package:flutter/material.dart';
import 'widgets/forgot_email_form.dart';
import '../../shared/widgets/otp_input_form.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/constants/asset_path.dart';

class ForgotPasswordView extends StatefulWidget {
  final String? email;

  const ForgotPasswordView({super.key, this.email});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> with SingleTickerProviderStateMixin {
  bool hasSentEmail = false;
  String? email;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    email = widget.email;
    hasSentEmail = false;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
              child: FadeTransition(
                opacity: _animController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
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
                      "Forgot Password",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasSentEmail
                          ? "Enter the 6-digit code we've just sent to your email."
                          : "Enter your email to receive a password reset code.",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w500,
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder: (child, anim) =>
                          SlideTransition(position: Tween<Offset>(
                              begin: const Offset(1, 0), end: Offset.zero).animate(anim), child: child),
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
                        onPressed: () => setState(() {
                          hasSentEmail = false;
                          email = null;
                        }),
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
      ),
    );
  }
}