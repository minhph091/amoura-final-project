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
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginOtpViewModel>(context);
    return FadeTransition(
      opacity: _animController,
      child: Form(
        key: viewModel.formKey,
        child: Column(
          children: [
            AppTextField(
              controller: viewModel.emailController,
              labelText: "Email",
              hintText: "Enter your email",
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              validator: ValidationUtil.validateEmail, // Sửa từ ValidationUtil().validateEmail
            ),
            const SizedBox(height: 24),
            AppButton(
              text: "Send OTP",
              icon: Icons.send,
              onPressed: viewModel.isLoading ? null : () => viewModel.onSendOtp(
                onSuccess: (email) => Navigator.of(context).pushNamed(
                  '/login-email-otp-verify',
                  arguments: {'email': email},
                ),
                onError: (error) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}