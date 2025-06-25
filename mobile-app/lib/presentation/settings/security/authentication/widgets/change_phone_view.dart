// lib/presentation/settings/security/authentication/widgets/change_phone_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/app_gradient_background.dart';
import 'change_phone_form_widget.dart';
import 'change_phone_viewmodel.dart';

class ChangePhoneView extends StatelessWidget {
  const ChangePhoneView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangePhoneViewModel>(
      create: (_) => ChangePhoneViewModel(),
      child: AppGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Change Phone Number'),
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
                    'Update Phone Number',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'To change your phone number, please enter your new number and verify with your password.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
