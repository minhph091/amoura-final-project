// lib/presentation/auth/reset_password/reset_password_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/reset_email_form.dart';
import 'widgets/new_password_form.dart';
import '../../shared/widgets/otp_input_form.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/constants/asset_path.dart';
import 'reset_password_viewmodel.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResetPasswordViewModel(email: email),
      child: Consumer<ResetPasswordViewModel>(
        builder: (context, viewModel, child) {
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
                          _getFormTitle(viewModel),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getFormSubtitle(viewModel),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        if (viewModel.sentEmail != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              viewModel.sentEmail!,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        const SizedBox(height: 28),
                        if (viewModel.isLoading)
                          const CircularProgressIndicator()
                        else if (viewModel.hasVerifiedOtp)
                          NewPasswordForm(
                            onSubmit: (password) async {
                              final success = await viewModel.resetPassword(password);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(viewModel.errorMessage ?? 'Password reset successfully'),
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                  ),
                                );
                                Navigator.pushReplacementNamed(context, '/login');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(viewModel.errorMessage ?? 'Failed to reset password'),
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                );
                              }
                            },
                          )
                        else if (viewModel.hasSentEmail)
                          OtpInputForm(
                            otpLength: 6,
                            onSubmit: (otp) => viewModel.onVerifyOtp(otp),
                            resendAvailable: true,
                            onResend: viewModel.onResendOtp,
                            errorMessage: viewModel.errorMessage,
                          )
                        else
                          ResetEmailForm(
                            onSend: (email) => viewModel.onSendEmail(email),
                          ),
                        if (viewModel.errorMessage != null &&
                            (!viewModel.hasSentEmail || viewModel.hasVerifiedOtp))
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              viewModel.errorMessage!,
                              style: TextStyle(
                                color: viewModel.errorMessage!.contains('successfully')
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
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

  String _getFormTitle(ResetPasswordViewModel viewModel) {
    if (viewModel.hasVerifiedOtp) {
      return "Create New Password";
    } else if (viewModel.hasSentEmail) {
      return "Verify Email";
    } else {
      return "Reset Password";
    }
  }

  String _getFormSubtitle(ResetPasswordViewModel viewModel) {
    if (viewModel.hasVerifiedOtp) {
      return "Create a new password for your account.";
    } else if (viewModel.hasSentEmail) {
      return "Enter the 6-digit code we've just sent to your email.";
    } else {
      return "Enter your email to receive a password reset code.";
    }
  }
}