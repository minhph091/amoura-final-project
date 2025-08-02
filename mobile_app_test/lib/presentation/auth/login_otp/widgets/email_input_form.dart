// lib/presentation/auth/login_otp/widgets/email_input_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../login_otp_viewmodel.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../../config/theme/app_colors.dart';

class EmailInputForm extends StatefulWidget {
  const EmailInputForm({super.key});

  @override
  State<EmailInputForm> createState() => _EmailInputFormState();
}

class _EmailInputFormState extends State<EmailInputForm> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<LoginOtpViewModel>(context, listen: false);
    viewModel.initAnimation(this);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginOtpViewModel>(context);
    return FadeTransition(
      opacity: viewModel.animController!,
      child: Form(
        key: viewModel.formKey,
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: viewModel.emailController,
                  labelText: "Email",
                  hintText: "Enter your email",
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  prefixIconColor: Theme.of(context).colorScheme.primary,
                  validator: ValidationUtil.validateEmail,
                ),
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    viewModel.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            AppButton(
              text: "Send OTP",
              onPressed: viewModel.isLoading
                  ? null
                  : () => viewModel.onSendOtp(
                        onSuccess: (email) => Navigator.of(context).pushNamed(
                          '/login-email-otp-verify',
                          arguments: {'email': email},
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
              textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              isLoading: viewModel.isLoading,
              loading: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
