import 'package:flutter/material.dart';
import 'package:amoura/config/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../../../config/language/app_localizations.dart';
import '../../../../../core/utils/validation_util.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import 'change_phone_viewmodel.dart';

class ChangePhoneFormWidget extends StatelessWidget {
  const ChangePhoneFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final viewModel = Provider.of<ChangePhoneViewModel>(context);

    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // New phone number field
          AppTextField(
            controller: viewModel.phoneController,
            labelText: localizations.translate('new_phone_number'),
            hintText: localizations.translate('new_phone_number_hint'),
            errorText: viewModel.phoneError,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_android,
            prefixIconColor: theme.colorScheme.primary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('phone_number_required');
              }
              // Basic phone number validation - can be enhanced for specific formats
              if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value)) {
                return localizations.translate('phone_number_invalid');
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Password field
          AppTextField(
            controller: viewModel.passwordController,
            labelText: localizations.translate('password'),
            hintText: localizations.translate('password_confirm_hint'),
            errorText: viewModel.passwordError,
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            prefixIconColor: theme.colorScheme.primary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            validator: (value) => ValidationUtil.validatePassword(value),
          ),
          const SizedBox(height: 32),

          // Change button
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: AppButton(
                text: localizations.translate('continue'),
                onPressed:
                    viewModel.isLoading
                        ? null
                        : () => viewModel.changePhoneNumber(context),
                isLoading: viewModel.isLoading,
                loading: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                textColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
