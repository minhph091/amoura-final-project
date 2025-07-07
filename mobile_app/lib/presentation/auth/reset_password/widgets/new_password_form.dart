import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../../config/theme/app_colors.dart';

class NewPasswordForm extends StatefulWidget {
  final Future<void> Function(String password) onSubmit;
  final bool isLoading;

  const NewPasswordForm({
    super.key, 
    required this.onSubmit,
    this.isLoading = false,
  });

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

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() == true) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }
      await widget.onSubmit(_passwordController.text);
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
              readOnly: widget.isLoading,
              prefixIcon: Icons.lock_outline,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: widget.isLoading ? null : () => setState(() => _obscurePassword = !_obscurePassword),
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
              readOnly: widget.isLoading,
              prefixIcon: Icons.lock_outline,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: widget.isLoading ? null : () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) => ValidationUtil.validatePassword(value),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: widget.isLoading ? "Resetting..." : "Reset Password",
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