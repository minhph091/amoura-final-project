// lib/presentation/auth/setup_profile/steps/step1_name_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amoura/core/utils/validation_util.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../setup_profile_viewmodel.dart';

class Step1NameForm extends StatefulWidget {
  const Step1NameForm({super.key});

  @override
  State<Step1NameForm> createState() => _Step1NameFormState();
}

class _Step1NameFormState extends State<Step1NameForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;

  @override
  void initState() {
    super.initState();
    final vm = context.read<SetupProfileViewModel>();
    _firstNameCtrl = TextEditingController(text: vm.firstName ?? "");
    _lastNameCtrl = TextEditingController(text: vm.lastName ?? "");
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                "Your Name",
                style: theme.textTheme.displayMedium?.copyWith(
                  fontFamily: AppTheme.lightTheme.textTheme.displayMedium?.fontFamily,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle căn giữa
            Align(
              alignment: Alignment.center,
              child: Text(
                "Your name will be visible to other users.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Fields marked * are required.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 18),
            // First Name Field
            AppTextField(
              controller: _firstNameCtrl,
              labelText: "First Name *",
              prefixIcon: Icons.person,
              prefixIconColor: colorScheme.primary,
              maxLength: 50,
              validator: ValidationUtil().validateFirstName,
              onSaved: (v) => vm.firstName = v?.trim(),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),

            // Last Name Field
            AppTextField(
              controller: _lastNameCtrl,
              labelText: "Last Name *",
              prefixIcon: Icons.badge,
              prefixIconColor: colorScheme.primary,
              maxLength: 50,
              validator: ValidationUtil().validateLastName,
              onSaved: (v) => vm.lastName = v?.trim(),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),

            // Next Button
            AppButton(
              text: "Next",
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  FocusScope.of(context).unfocus();
                  _formKey.currentState!.save();
                  vm.nextStep();
                }
              },
              width: double.infinity,
              height: 52,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.secondary,
                ],
              ),
              textStyle: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
