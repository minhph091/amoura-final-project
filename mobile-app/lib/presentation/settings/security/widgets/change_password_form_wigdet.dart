import 'package:flutter/material.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../authentication/widgets/change_password_viewmodel.dart';

class ChangePasswordFormWidget extends StatelessWidget {
  const ChangePasswordFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = ChangePasswordViewModel();

    final theme = Theme.of(context);
    final color = theme.brightness == Brightness.dark
        ? const Color(0xFFFF69B4) // Hồng sáng như AppBar ở dark mode
        : theme.textTheme.headlineMedium?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update your password',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: viewModel.currentPasswordController,
            labelText: 'Current Password',
            errorText: viewModel.currentPasswordError,
            obscureText: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: viewModel.newPasswordController,
            labelText: 'New Password',
            errorText: viewModel.newPasswordError,
            obscureText: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: viewModel.confirmPasswordController,
            labelText: 'Confirm New Password',
            errorText: viewModel.confirmPasswordError,
            obscureText: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: AppButton(
                text: 'Save Changes',
                onPressed: viewModel.isLoading
                    ? null
                    : () => viewModel.submit(context),
                isLoading: viewModel.isLoading,
                loading: const CircularProgressIndicator(color: Colors.white),
                color: Theme.of(context).colorScheme.primary,
                height: 52,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}