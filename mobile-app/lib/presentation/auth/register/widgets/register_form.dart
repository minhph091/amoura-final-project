// lib/presentation/auth/register/widgets/register_form.dart

import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../login_otp/widgets/otp_input_form.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtl = TextEditingController();
  final TextEditingController _phoneCtl = TextEditingController();
  final TextEditingController _passwordCtl = TextEditingController();
  final TextEditingController _confirmCtl = TextEditingController();
  bool _obscurePwd = true;
  bool _obscureConfirm = true;
  bool showOtp = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _phoneCtl.dispose();
    _passwordCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return showOtp
        ? OtpInputForm(
      otpLength: 6,
      onSubmit: (otp) {
        // Để backend xử lý xác thực OTP
      },
      resendAvailable: true,
      onResend: () {
        // Để backend xử lý gửi lại OTP
      },
    )
        : Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _emailCtl,
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
            controller: _phoneCtl,
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
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _confirmCtl,
            labelText: "Confirm password",
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirm,
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm password';
              if (v != _passwordCtl.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  setState(() => showOtp = true);
                }
              },
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text("Register"),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account?",
                  style: Theme.of(context).textTheme.bodyMedium),
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