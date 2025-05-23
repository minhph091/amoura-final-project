// lib/presentation/auth/reset_password/reset_password_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/reset_email_form.dart';
import 'widgets/new_password_form.dart';
import '../../shared/widgets/otp_input_form.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/constants/asset_path.dart';
import 'reset_password_viewmodel.dart';

class ResetPasswordView extends StatefulWidget {
  final String? email;
  const ResetPasswordView({super.key, this.email});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> with SingleTickerProviderStateMixin {
  bool _hasSentEmail = false;
  bool _hasVerifiedOtp = false;
  String? _email;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _email = widget.email;
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

  String _getFormTitle() {
    if (_hasVerifiedOtp) return "Create New Password";
    else if (_hasSentEmail) return "Verify Email";
    else return "Forgot Password";
  }

  String _getFormSubtitle() {
    if (_hasVerifiedOtp) return "Create a new password for your account.";
    else if (_hasSentEmail) return "Enter the 6-digit code we've just sent to your email.";
    else return "Enter your email to receive a password reset code.";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => ResetPasswordViewmodel(),
      child: Consumer<ResetPasswordViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(gradient: _getBackgroundGradient(context)),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: FadeTransition(
                      opacity: _animController,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: "amoura_logo",
                            child: Image.asset(AssetPath.logo, width: 70, height: 70),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            _getFormTitle(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getFormSubtitle(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_email != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                _email!,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 28),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            transitionBuilder: (child, anim) => SlideTransition(
                              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(anim),
                              child: child,
                            ),
                            child: !_hasSentEmail
                                ? ResetEmailForm(
                                    key: const ValueKey('email-form'),
                                    onSend: (val) {
                                      setState(() {
                                        _email = val;
                                        viewModel.onSendEmail(val);
                                        _hasSentEmail = true;
                                      });
                                    },
                                  )
                                : _hasVerifiedOtp
                                    ? NewPasswordForm(
                                        key: const ValueKey('password-form'),
                                        onSubmit: (password) {
                                          viewModel.onResetPassword(_email!, password);
                                        },
                                      )
                                    : OtpInputForm(
                                        key: const ValueKey('otp-form'),
                                        otpLength: 6,
                                        onSubmit: (otp) {
                                          viewModel.onVerifyOtp(otp);
                                          setState(() {
                                            _hasVerifiedOtp = true;
                                          });
                                        },
                                        resendAvailable: viewModel.canResend, // Sử dụng canResend từ viewModel
                                        onResend: viewModel.onResendOtp,
                                        remainingSeconds: viewModel.remainingSeconds, // Truyền remainingSeconds
                                      ),
                          ),
                          const SizedBox(height: 18),
                          if (_hasVerifiedOtp)
                            TextButton.icon(
                              onPressed: () => setState(() => _hasVerifiedOtp = false),
                              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                              label: const Text("Back to Verification"),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                                textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            )
                          else if (_hasSentEmail)
                            TextButton.icon(
                              onPressed: () => setState(() => _hasSentEmail = false),
                              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                              label: const Text("Back to Email"),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                                textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (viewModel.isLoading) ...[
                            const SizedBox(height: 12),
                            const CircularProgressIndicator(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}