// lib/presentation/auth/login_otp/widgets/email_input_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../login_otp_viewmodel.dart';
import '../../../../core/utils/validation_util.dart';

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
              icon: Icons.send,
              onPressed: viewModel.isLoading
                  ? null
                  : () => viewModel.onSendOtp(
                        onSuccess: (email) => Navigator.of(context).pushNamed(
                          '/login-email-otp-verify',
                          arguments: {'email': email},
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}