import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../../core/utils/validation_util.dart';

class NewPasswordForm extends StatefulWidget {
  final void Function(String password) onSubmit;

  const NewPasswordForm({super.key, required this.onSubmit});

  @override
  State<NewPasswordForm> createState() => _NewPasswordFormState();
}

class _NewPasswordFormState extends State<NewPasswordForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() == true) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')), // Thông báo lỗi bằng tiếng Anh
        );
        return;
      }
      widget.onSubmit(_passwordController.text);
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
              labelText: "New Password",
              hintText: "Enter your new password",
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) => ValidationUtil.validatePassword(value),
            ),
            const SizedBox(height: 16),
            AppTextField(
              labelText: "Confirm Password",
              hintText: "Confirm your new password",
              controller: _confirmPasswordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: _obscureConfirmPassword,
              prefixIcon: Icons.lock_outline,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) => ValidationUtil.validatePassword(value),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_rounded),
                onPressed: _onSubmit,
                label: const Text("Reset Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}