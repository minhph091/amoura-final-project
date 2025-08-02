// lib/presentation/settings/security/authentication/widgets/change_phone_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../config/language/app_localizations.dart';
import '../../../../shared/widgets/app_gradient_background.dart';
import 'change_phone_form_widget.dart';
import 'change_phone_viewmodel.dart';

class ChangePhoneView extends StatelessWidget {
  const ChangePhoneView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return ChangeNotifierProvider<ChangePhoneViewModel>(
      create: (_) => ChangePhoneViewModel(),
      child: AppGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(localizations.translate('change_phone')),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    localizations.translate('update_phone_number'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.translate('phone_change_info'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const ChangePhoneFormWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

