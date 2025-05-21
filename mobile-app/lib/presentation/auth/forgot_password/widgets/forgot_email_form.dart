// lib/presentation/auth/forgot_password/widgets/forgot_email_form.dart

import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../../core/utils/validation_util.dart';

class ForgotEmailForm extends StatefulWidget {
  final void Function(String email) onSend;

  const ForgotEmailForm({super.key, required this.onSend});

  @override
  State<ForgotEmailForm> createState() => _ForgotEmailFormState();
}

class _ForgotEmailFormState extends State<ForgotEmailForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0,
      upperBound: 10,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() == true) {
      widget.onSend(_emailController.text.trim());
    } else {
      _shakeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeController.value, 0),
        child: child,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              labelText: "Email",
              hintText: "Enter your email",
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              onChanged: (_) => setState(() {}),
              errorText: ValidationUtil.validateEmail(_emailController.text),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send_rounded),
                onPressed: _onSubmit,
                label: const Text("Send Code"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}