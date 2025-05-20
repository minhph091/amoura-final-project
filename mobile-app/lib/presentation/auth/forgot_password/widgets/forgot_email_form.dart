// lib/presentation/auth/forgot_password/widgets/forgot_email_form.dart

import 'package:flutter/material.dart';

class ForgotEmailForm extends StatefulWidget {
  final void Function(String email) onSend;

  const ForgotEmailForm({Key? key, required this.onSend}) : super(key: key);

  @override
  State<ForgotEmailForm> createState() => _ForgotEmailFormState();
}

class _ForgotEmailFormState extends State<ForgotEmailForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email_rounded),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter email";
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return "Invalid email";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  widget.onSend(_emailController.text.trim());
                }
              },
              child: const Text("Send Code"),
            ),
          ),
        ],
      ),
    );
  }
}