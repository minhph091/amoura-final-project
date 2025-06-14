import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/otp_input_form.dart';
import '../../../../../config/theme/app_colors.dart';
import 'change_email_viewmodel.dart';

class EmailOtpForm extends StatelessWidget {
  final ChangeEmailViewModel viewModel;

  const EmailOtpForm({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? const Color(0xFFFF69B4)
        : theme.textTheme.headlineMedium?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verify Email Change',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'We\'ve sent a verification code to ${viewModel.emailController.text}. Please enter the 6-digit code to confirm the change.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),
          OtpInputForm(
            otpLength: 6,
            onSubmit: (otp) {
              viewModel.otpController.text = otp;
              viewModel.verifyOtpAndChangeEmail(context);
            },
            resendAvailable: viewModel.canResend,
            onResend: () => viewModel.resendOtp(context),
            remainingSeconds: viewModel.remainingSeconds,
            errorMessage: viewModel.otpError,
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: AppButton(
                text: 'Verify',
                onPressed: viewModel.isLoading ? null : () => viewModel.verifyOtpAndChangeEmail(context),
                isLoading: viewModel.isLoading,
                loading: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary.withValues(alpha: 0.85)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                textColor: Colors.white,
                elevation: 7,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
