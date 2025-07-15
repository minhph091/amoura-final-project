import 'package:flutter/material.dart';
import '../../../../../core/utils/validation_util.dart';
import '../../../../../config/language/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../../config/theme/app_colors.dart';
import 'change_email_viewmodel.dart';

class EmailPasswordForm extends StatelessWidget {
  final ChangeEmailViewModel viewModel;

  const EmailPasswordForm({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? const Color(0xFFFF69B4)
        : theme.textTheme.headlineMedium?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: viewModel.passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.translate('verify_identity'),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('password_continue'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: viewModel.passwordController,
              labelText: localizations.translate('current_password'),
              hintText: localizations.translate('current_password_hint'),
              errorText: viewModel.passwordError,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              prefixIconColor: theme.colorScheme.primary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              validator: ValidationUtil.validatePassword,
            ),
            const SizedBox(height: 32),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: AppButton(
                  text: localizations.translate('continue'),
                  onPressed: viewModel.isLoading ? null : () => viewModel.verifyPassword(context),
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
                    colors: [AppColors.primary, AppColors.secondary.withValues(alpha: 0.85)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  textColor: Colors.white,
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
