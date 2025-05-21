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
  bool _loading = false;

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
      setState(() => _loading = true);
      await Future.delayed(const Duration(milliseconds: 600));
      widget.onLogin?.call(_accountCtl.text.trim(), _passwordCtl.text);
      setState(() => _loading = false);
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
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter email or phone';
                if (!ValidationUtil.isEmail(v) && !ValidationUtil.isPhoneNumber(v)) {
                  return 'Invalid email or phone';
                }
                return null;
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
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter password';
                if (!ValidationUtil.isPasswordValid(v)) {
                  return 'Password must be at least 8 chars, có chữ HOA, thường, số, ký tự đặc biệt';
                }
                return null;
              },
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