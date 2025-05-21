// lib/presentation/auth/login_otp/widgets/email_input_form.dart

import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../shared/widgets/app_button.dart';

class EmailInputForm extends StatefulWidget {
  final void Function(String email) onSend;

  const EmailInputForm({super.key, required this.onSend});

  @override
  State<EmailInputForm> createState() => _EmailInputFormState();
}

class _EmailInputFormState extends State<EmailInputForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtl = TextEditingController();
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
    _emailCtl.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _loading = true);
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onSend(_emailCtl.text.trim());
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
              controller: _emailCtl,
              labelText: "Email",
              hintText: "Enter your email",
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              validator: (v) => ValidationUtil.validateEmail(v),
              errorText: null,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: "Send OTP",
              icon: Icons.send,
              isLoading: _loading,
              onPressed: _onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}