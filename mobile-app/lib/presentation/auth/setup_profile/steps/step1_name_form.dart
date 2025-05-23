// lib/presentation/auth/setup_profile/steps/step1_name_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validation_util.dart';
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
            Text(
              "Your Name",
              style: theme.textTheme.headlineLarge?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "This name will be visible to everyone.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Fields marked with * are required.",
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => vm.skipStep(),
                  child: const Text("Skip"),
                ),
                AppButton(
                  text: "Next",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      _formKey.currentState!.save();
                      await vm.nextStep(context);
                    }
                  },
                  width: double.infinity,
                  height: 52,
                  useThemeGradient: true,
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}