// lib/presentation/auth/register/widgets/register_form.dart

import 'package:amoura/core/utils/validation_util.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/otp_input_form.dart';
import '../register_viewmodel.dart';

class RegisterForm extends StatelessWidget {
  final RegisterViewModel viewModel;

  const RegisterForm({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.showOtp) {
      return OtpInputForm(
        otpLength: 6,
        onSubmit: (otp) => viewModel.verifyOtp(context, otp),
        resendAvailable: true,
        onResend: viewModel.initiateRegistration,
      );
    }

    return Form(
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
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: viewModel.phoneController,
            labelText: "Phone number",
            hintText: "Enter your phone number",
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            prefixIconColor: Theme.of(context).colorScheme.primary,
            validator: ValidationUtil().validatePhone,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: viewModel.passwordController,
            labelText: "Password",
            hintText: "Create a password",
            obscureText: viewModel.obscurePassword,
            prefixIcon: Icons.lock_outline,
            prefixIconColor: Theme.of(context).colorScheme.primary,
            suffixIcon: IconButton(
              icon: Icon(viewModel.obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: viewModel.toggleObscurePassword,
            ),
            validator: ValidationUtil().validatePassword,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: viewModel.confirmController,
            labelText: "Confirm password",
            hintText: "Re-enter your password",
            obscureText: viewModel.obscureConfirm,
            prefixIcon: Icons.lock_outline,
            prefixIconColor: Theme.of(context).colorScheme.primary,
            suffixIcon: IconButton(
              icon: Icon(viewModel.obscureConfirm ? Icons.visibility_off : Icons.visibility),
              onPressed: viewModel.toggleObscureConfirm,
            ),
            validator: (value) => ValidationUtil().validateConfirmPassword(
              value,
              viewModel.passwordController.text,
            ),
          ),
          const SizedBox(height: 22),
          AppButton(
            text: "Register",
            icon: Icons.person_add_alt_1,
            loading: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            onPressed: viewModel.isLoading ? null : viewModel.initiateRegistration,
          ),
          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              viewModel.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account?",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text("Sign in now"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}