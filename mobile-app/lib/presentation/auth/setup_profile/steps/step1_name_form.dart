// lib/presentation/auth/setup_profile/steps/step1_name_form.dart
// Form widget for collecting the user's first and last name in the profile setup process.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../shared/widgets/shake_widget.dart';
import '../widgets/setup_profile_button.dart';
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
  bool _firstNameError = false;
  bool _lastNameError = false;

  // Initialize controllers with existing data from the view model.
  @override
  void initState() {
    super.initState();
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    _firstNameCtrl = TextEditingController(text: vm.firstName ?? "");
    _lastNameCtrl = TextEditingController(text: vm.lastName ?? "");
  }

  // Dispose controllers to prevent memory leaks.
  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  // Validate form inputs and save data to the view model.
  void _validateAndSave() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _firstNameError = false;
        _lastNameError = false;
      });
    } else {
      setState(() {
        _firstNameError = ValidationUtil().validateFirstName(_firstNameCtrl.text) != null;
        _lastNameError = ValidationUtil().validateLastName(_lastNameCtrl.text) != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final theme = Theme.of(context);

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
                color: const Color(0xFFD81B60), // Deep pink for step titles
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "This name will be visible to everyone.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFAB47BC), // Lighter purple for descriptions
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Fields marked with * are required.",
              style: theme.textTheme.labelLarge?.copyWith(
                color: const Color(0xFFAB47BC),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            ShakeWidget(
              shake: _firstNameError,
              child: AppTextField(
                controller: _firstNameCtrl,
                labelText: "First Name *",
                labelStyle: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFBA68C8), // Muted purple for field labels
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Icons.person,
                prefixIconColor: const Color(0xFFD81B60),
                maxLength: 50,
                validator: (v) => ValidationUtil().validateFirstName(v),
                onSaved: (v) => vm.firstName = v?.trim(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF424242), // Dark gray for input text
                ),
              ),
            ),
            const SizedBox(height: 18),
            ShakeWidget(
              shake: _lastNameError,
              child: AppTextField(
                controller: _lastNameCtrl,
                labelText: "Last Name *",
                labelStyle: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFBA68C8),
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Icons.badge,
                prefixIconColor: const Color(0xFFD81B60),
                maxLength: 50,
                validator: (v) => ValidationUtil().validateLastName(v),
                onSaved: (v) => vm.lastName = v?.trim(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF424242),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SetupProfileButton(
              text: "Next",
              onPressed: () {
                _validateAndSave();
                if (!_firstNameError && !_lastNameError) {
                  FocusScope.of(context).unfocus();
                  vm.nextStep();
                }
              },
              width: double.infinity,
              height: 52,
            ),
          ],
        ),
      ),
    );
  }
}