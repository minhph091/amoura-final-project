// lib/presentation/auth/login/widgets/login_form.dart

import 'package:flutter/material.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';

class LoginForm extends StatefulWidget {
  final void Function(String account, String password)? onLogin;

  const LoginForm({super.key, this.onLogin});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountCtl = TextEditingController();
  final TextEditingController _passwordCtl = TextEditingController();
  bool _obscurePwd = true;

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
    _accountCtl.dispose();
    _passwordCtl.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await Future.delayed(const Duration(milliseconds: 600));
      widget.onLogin?.call(_accountCtl.text.trim(), _passwordCtl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animController,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              controller: _accountCtl,
              labelText: "Email or Phone",
              hintText: "Enter email or phone",
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.person_outline,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              errorText: null,
              validator: (value) {
                final emailError = ValidationUtil().validateEmail(value);
                final phoneError = ValidationUtil().validatePhone(value);
                // If either validation passes (returns null), the input is valid
                if (emailError == null || phoneError == null) {
                  return null;
                }
                // Both validations failed, return a descriptive error
                return "Please enter a valid email or phone number";
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordCtl,
              labelText: "Password",
              hintText: "Enter your password",
              obscureText: _obscurePwd,
              prefixIcon: Icons.lock_outline,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              suffixIcon: IconButton(
                icon: Icon(_obscurePwd ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
              ),
              errorText: null,
              validator: ValidationUtil().validatePassword,
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
              onPressed: _onLogin,
            ),
          ],
        ),
      ),
    );
  }
}