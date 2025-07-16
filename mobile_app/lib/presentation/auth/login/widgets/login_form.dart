// lib/presentation/auth/login/widgets/login_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../login_viewmodel.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/language/app_localizations.dart';
import '../../../profile/view/profile_viewmodel.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
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
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
    final localizations = AppLocalizations.of(context);

    return FadeTransition(
      opacity: _animController,
      child: Form(
        key: viewModel.formKey,
        child: Column(
          children: [
            AppTextField(
              controller: viewModel.accountController,
              labelText: localizations.translate("email_phone"),
              hintText: localizations.translate("email_phone_hint"),
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.person_outline,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              validator: (value) {
                final emailError = ValidationUtil.validateEmail(value);
                final phoneError = ValidationUtil.validatePhone(value);
                if (emailError == null || phoneError == null) {
                  return null;
                }
                return "Please enter a valid email or phone number";
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: viewModel.passwordController,
              labelText: localizations.translate("password"),
              hintText: localizations.translate("password_hint"),
              obscureText: viewModel.obscurePassword,
              prefixIcon: Icons.lock_outline,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: viewModel.toggleObscurePassword,
              ),
              validator: ValidationUtil.validatePassword,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/forgot-password');
                },
                child: Text(localizations.translate("forgot_password")),
              ),
            ),
            const SizedBox(height: 8),
            AppButton(
              text: localizations.translate("sign_in"),
              onPressed:
                  viewModel.isLoading
                      ? null
                      : () => viewModel.onLoginPressed(
                        onSuccess: () async {
                          await Provider.of<ProfileViewModel>(
                            context,
                            listen: false,
                          ).loadProfile();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/mainNavigator',
                              (route) => false,
                            );
                          }
                        },
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
              isLoading: viewModel.isLoading,
              loading: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            if (viewModel.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                localizations.translate("login_error"),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
