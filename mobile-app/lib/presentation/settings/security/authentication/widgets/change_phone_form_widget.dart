// filepath: c:\amoura-final-project\mobile-app\lib\presentation\settings\security\authentication\widgets\change_phone_form_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/utils/validation_util.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import 'change_phone_viewmodel.dart';

class ChangePhoneFormWidget extends StatelessWidget {
  const ChangePhoneFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? const Color(0xFFFF69B4)
        : theme.textTheme.headlineMedium?.color ?? Colors.black87;

    final viewModel = Provider.of<ChangePhoneViewModel>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Phone Number',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter your new phone number and confirm with your password.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 32),

              // New phone number field
              AppTextField(
                controller: viewModel.phoneController,
                labelText: 'New Phone Number',
                hintText: 'Enter your new phone number',
                errorText: viewModel.phoneError,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_android,
                prefixIconColor: theme.colorScheme.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  // Basic phone number validation - can be enhanced for specific formats
                  if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Password field
              AppTextField(
                controller: viewModel.passwordController,
                labelText: 'Password',
                hintText: 'Enter your password to confirm',
                errorText: viewModel.passwordError,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                prefixIconColor: theme.colorScheme.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                validator: (value) => ValidationUtil.validatePassword(value),
              ),
              const SizedBox(height: 32),

              // Change button
              AppButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () => viewModel.changePhoneNumber(context),
                text: 'Change Phone Number',
                isLoading: viewModel.isLoading,
                width: double.infinity,
                color: theme.colorScheme.primary,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
