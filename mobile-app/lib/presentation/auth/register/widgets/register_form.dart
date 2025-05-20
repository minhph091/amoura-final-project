import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../register_viewmodel.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/otp_input_form.dart';

class RegisterForm extends StatelessWidget {
  final RegisterViewModel viewModel;

  const RegisterForm({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
        return viewModel.showOtp
            ? OtpInputForm(
                otpLength: 6,
                onSubmit: (otp) {
                  // Sẽ xử lý xác thực OTP ở bước sau
                },
                resendAvailable: true,
                onResend: () {
                  viewModel.initiateRegistration(); // Gửi lại OTP
                },
              )
            : Form(
                key: viewModel.formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: viewModel.emailController,
                      labelText: "Email",
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter your email';
                        final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                        if (!emailRegex.hasMatch(v.trim())) return 'Invalid email format';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: viewModel.phoneController,
                      labelText: "Phone number",
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter your phone number';
                        if (!RegExp(r"^[0-9]{8,15}$").hasMatch(v.trim())) return "Invalid phone number";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: viewModel.passwordController,
                      labelText: "Password",
                      prefixIcon: Icons.lock_outline,
                      obscureText: viewModel.obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(viewModel.obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: viewModel.toggleObscurePassword,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter password';
                        if (v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: viewModel.confirmController,
                      labelText: "Confirm password",
                      prefixIcon: Icons.lock_outline,
                      obscureText: viewModel.obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(viewModel.obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: viewModel.toggleObscureConfirm,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please confirm password';
                        if (v != viewModel.passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: viewModel.isLoading ? null : viewModel.initiateRegistration,
                        icon: const Icon(Icons.person_add_alt_1),
                        label: viewModel.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Register"),
                      ),
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
      },
    );
  }
}