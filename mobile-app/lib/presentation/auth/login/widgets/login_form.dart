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
  _LoginFormState createState() => _LoginFormState();
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
      final viewModel = Provider.of<LoginViewModel>(context, listen: false);
      await viewModel.onLoginPressed(context, _accountCtl.text.trim(), _passwordCtl.text); // Gọi với 3 tham số
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
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
              prefixIcon: Icons.email_outlined,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Please enter a valid email or phone number';
                if (!ValidationUtil.isEmail(value) && !ValidationUtil.isPhoneNumber(value)) {
                  return 'Please enter a valid email or phone number';
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
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter a password';
                if (!ValidationUtil.isPasswordValid(value)) {
                  return 'Password must be at least 8 characters with uppercase, lowercase, number, and special character';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/forgot-password'),
                child: const Text("Forgot password?"),
              ),
            ),
            const SizedBox(height: 8),
            AppButton(
              text: "Sign In",
              icon: Icons.login,
              onPressed: _onLogin,
              isLoading: viewModel.isLoading,
            ),
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}