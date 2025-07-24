// lib/presentation/auth/register/widgets/register_form.dart
import 'package:flutter/material.dart';
import '../../../../core/utils/localized_validation.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/language/app_localizations.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/otp_input_form.dart';
import 'terms_agreement_widget.dart';
import '../register_viewmodel.dart';

class RegisterForm extends StatelessWidget {
  final RegisterViewModel viewModel;

  const RegisterForm({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final validator = LocalizedValidation.of(context);

    if (viewModel.showOtp) {
      return OtpInputForm(
        otpLength: 6,
        onSubmit: (otp) => viewModel.verifyOtp(context, otp),
        resendAvailable: viewModel.canResend,
        onResend: viewModel.resendOtp,
        remainingSeconds: viewModel.remainingSeconds,
        errorMessage: viewModel.errorMessage,
      );
    }

    return Form(
      key: viewModel.formKey,
      child: Column(
        children: [
          AppTextField(
            controller: viewModel.emailController,
            labelText: localizations.translate("email"),
            hintText: localizations.translate("email_hint"),
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            prefixIconColor: theme.colorScheme.primary,
            validator: validator.validateEmail,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: viewModel.phoneController,
            labelText: localizations.translate("phone_number"),
            hintText: localizations.translate("phone_hint"),
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            prefixIconColor: theme.colorScheme.primary,
            validator: validator.validatePhone,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: viewModel.passwordController,
            labelText: localizations.translate("password_create"),
            hintText: localizations.translate("password_create_hint"),
            obscureText: viewModel.obscurePassword,
            prefixIcon: Icons.lock_outline,
            prefixIconColor: theme.colorScheme.primary,
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: viewModel.toggleObscurePassword,
            ),
            validator: validator.validatePassword,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: viewModel.confirmController,
            labelText: localizations.translate("confirm_password"),
            hintText: localizations.translate("confirm_password_hint"),
            obscureText: viewModel.obscureConfirm,
            prefixIcon: Icons.lock_outline,
            prefixIconColor: theme.colorScheme.primary,
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.obscureConfirm
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: viewModel.toggleObscureConfirm,
            ),
            validator:
                (value) => validator.validateConfirmPassword(
                  viewModel.passwordController.text,
                  value,
                ),
          ),

          // Add Terms Agreement Widget
          TermsAgreementWidget(
            isAgreed: viewModel.termsAgreed,
            onChanged: viewModel.toggleTermsAgreement,
            localizations: localizations,
          ),

          const SizedBox(height: 22),
          AppButton(
            text: localizations.translate("register"),
            isLoading: viewModel.isLoading,
            loading: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            onPressed:
                viewModel.isLoading
                    ? null
                    : () => viewModel.initiateRegistration(context),
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary.withValues(alpha: 0.85),
              ],
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
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.translate("already_have_account"),
                style: theme.textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text(localizations.translate("sign_in_now")),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
