import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amoura/core/utils/validation_util.dart';
import '../../../../config/language/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../../config/theme/app_colors.dart';
import '../authentication/widgets/change_password_viewmodel.dart';

class ChangePasswordFormWidget extends StatefulWidget {
  const ChangePasswordFormWidget({super.key});

  @override
  State<ChangePasswordFormWidget> createState() =>
      _ChangePasswordFormWidgetState();
}

class _ChangePasswordFormWidgetState extends State<ChangePasswordFormWidget> {
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final color =
        theme.brightness == Brightness.dark
            ? const Color(0xFFFF69B4)
            : theme.textTheme.headlineMedium?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Consumer<ChangePasswordViewModel>(
        builder: (context, viewModel, _) {
          return Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.translate('update_your_password'),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: viewModel.currentPasswordController,
                  labelText: localizations.translate('current_password'),
                  obscureText: !_showCurrentPassword,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showCurrentPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showCurrentPassword = !_showCurrentPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.translate(
                        'current_password_required',
                      );
                    }
                    if (viewModel.currentPasswordError != null) {
                      return viewModel.currentPasswordError;
                    }
                    return null;
                  },
                  onChanged: (_) {
                    if (_formKey.currentState != null)
                      _formKey.currentState!.validate();
                  },
                ),
                const SizedBox(height: 28),
                AppTextField(
                  controller: viewModel.newPasswordController,
                  labelText: localizations.translate('new_password'),
                  obscureText: !_showNewPassword,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showNewPassword = !_showNewPassword;
                      });
                    },
                  ),
                  validator: (value) => ValidationUtil.validatePassword(value),
                  onChanged: (_) {
                    if (_formKey.currentState != null)
                      _formKey.currentState!.validate();
                  },
                ),
                const SizedBox(height: 28),
                AppTextField(
                  controller: viewModel.confirmPasswordController,
                  labelText: localizations.translate('confirm_new_password'),
                  obscureText: !_showConfirmPassword,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                  validator:
                      (value) => ValidationUtil.validateConfirmPassword(
                        viewModel.newPasswordController.text,
                        value,
                      ),
                  onChanged: (_) {
                    if (_formKey.currentState != null)
                      _formKey.currentState!.validate();
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: AppButton(
                      text: localizations.translate('continue'),
                      onPressed:
                          viewModel.isLoading
                              ? null
                              : () async {
                                // Reset lỗi current password trước khi submit
                                viewModel.currentPasswordError = null;
                                if (_formKey.currentState!.validate()) {
                                  await viewModel.submit(context);
                                  // Nếu có lỗi từ API, ép form validate lại để hiển thị
                                  if (viewModel.currentPasswordError != null) {
                                    _formKey.currentState!.validate();
                                  }
                                }
                              },
                      isLoading: viewModel.isLoading,
                      loading: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
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
                      height: 52,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
