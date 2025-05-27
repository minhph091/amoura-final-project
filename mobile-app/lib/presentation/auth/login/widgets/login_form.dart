// lib/presentation/auth/login/widgets/login_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../login_viewmodel.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with SingleTickerProviderStateMixin {
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
    final viewModel = Provider.of<LoginViewModel>(context);
    return FadeTransition(
      opacity: _animController,
      child: Form(
        key: viewModel.formKey,
        child: Column(
          children: [
            AppTextField(
              controller: viewModel.accountController,
              labelText: "Email or Phone",
              hintText: "Enter email or phone",
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.person_outline,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              validator: (value) {
                final emailError = ValidationUtil.validateEmail(value);
                final phoneError = ValidationUtil.validatePhone(value);
                if (emailError == null || phoneError == null) {
                  return null;
                }
                return "Please enter a valid email or phone number";
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: viewModel.passwordController,
              labelText: "Password",
              hintText: "Enter your password",
              obscureText: viewModel.obscurePassword,
              prefixIcon: Icons.lock_outline,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              suffixIcon: IconButton(
                icon: Icon(viewModel.obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: viewModel.toggleObscurePassword,
              ),
              validator: ValidationUtil.validatePassword,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/forgot-password');
                },
                child: const Text("Forgot password?"),
              ),
            ),
            const SizedBox(height: 8),
            AppButton(
              text: "Sign In",
              icon: Icons.login,
              onPressed: viewModel.isLoading
                  ? null
                  : () => viewModel.onLoginPressed(
                        onSuccess: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/mainNavigator',
                            (route) => false, // Xóa tất cả các route trước đó
                          );
                        },
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
          ],
        ),
      ),
    );
  }
}