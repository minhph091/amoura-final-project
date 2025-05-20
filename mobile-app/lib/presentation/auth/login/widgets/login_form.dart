// lib/presentation/auth/login/widgets/login_form.dart

import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountCtl = TextEditingController();
  final TextEditingController _passwordCtl = TextEditingController();
  bool _obscurePwd = true;

  @override
  void dispose() {
    _accountCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _accountCtl,
            labelText: "Email or Phone",
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter email or phone';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _passwordCtl,
            labelText: "Password",
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePwd,
            suffixIcon: IconButton(
              icon: Icon(_obscurePwd ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter password';
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text("Sign in"),
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  // Xử lý login: Để backend xử lý. Frontend chỉ validate và submit.
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}