// lib/presentation/auth/reset_password/widgets/reset_email_form.dart
import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../../config/theme/app_colors.dart';

class ResetEmailForm extends StatefulWidget {
  final Future<void> Function(String email) onSend;
  final bool isLoading;

  const ResetEmailForm({
    super.key, 
    required this.onSend,
    this.isLoading = false,
  });

  @override
  State<ResetEmailForm> createState() => _ResetEmailFormState();
}

class _ResetEmailFormState extends State<ResetEmailForm> with SingleTickerProviderStateMixin {
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

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() == true) {
      await widget.onSend(_emailController.text.trim());
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
              readOnly: widget.isLoading,
              prefixIcon: Icons.email_outlined,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              onChanged: (_) => setState(() {}),
              validator: (value) => ValidationUtil.validateEmail(value ?? ''),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: widget.isLoading ? "Sending..." : "Send Code",
              onPressed: widget.isLoading ? null : _onSubmit,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary.withValues(alpha: 0.85)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              textColor: Colors.white,
              elevation: 7,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
