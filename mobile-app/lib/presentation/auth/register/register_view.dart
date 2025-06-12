// lib/presentation/auth/register/register_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_viewmodel.dart';
import 'widgets/register_form.dart';
import '../../../core/constants/asset_path.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/language/app_localizations.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  LinearGradient _getBackgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBackground,
              AppColors.darkSecondary.withValues(alpha: 0.90),
              AppColors.darkPrimary.withValues(alpha: 0.82),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.primary.withValues(alpha: 0.13),
              AppColors.secondary.withValues(alpha: 0.06),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: _getBackgroundGradient(context),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: "amoura_logo",
                          child: Image.asset(
                            AssetPath.logo,
                            width: 70,
                            height: 70,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          localizations.translate("create_account"),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        RegisterForm(viewModel: viewModel),
                        if (viewModel.errorMessage != null && !viewModel.showOtp) ...[
                          const SizedBox(height: 12),
                          Text(
                            viewModel.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}