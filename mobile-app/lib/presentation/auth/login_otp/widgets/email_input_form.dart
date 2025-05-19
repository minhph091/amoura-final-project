// lib/presentation/auth/login_otp/widgets/email_input_form.dart

import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart';

class EmailInputForm extends StatefulWidget {
  final void Function(String email) onSend;

  const EmailInputForm({super.key, required this.onSend});

  @override
  State<EmailInputForm> createState() => _EmailInputFormState();
}

class _EmailInputFormState extends State<EmailInputForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtl = TextEditingController();

  @override
  void dispose() {
    _emailCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.onSend(_emailCtl.text.trim());
                }
              },
              icon: const Icon(Icons.send),
              label: const Text("Send OTP"),
            ),
          ),
        ],
      ),
    );
  }
}