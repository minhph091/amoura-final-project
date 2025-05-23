// lib/presentation/auth/setup_profile/steps/step2_dob_gender_form.dart
// Form widget for collecting the user's date of birth and gender.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/date_util.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../shared/widgets/shake_widget.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../../../../core/constants/profile/sex_constants.dart';
import '../setup_profile_viewmodel.dart';

class Step2DobGenderForm extends StatefulWidget {
  const Step2DobGenderForm({super.key});

  @override
  State<Step2DobGenderForm> createState() => _Step2DobGenderFormState();
}

class _Step2DobGenderFormState extends State<Step2DobGenderForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dobController;
  bool _dobError = false;
  bool _genderError = false;

  late SetupProfileViewModel _viewModel;

  // Initialize the date of birth controller with existing data.
  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<SetupProfileViewModel>(context, listen: false);
    _dobController = TextEditingController(
      text: _viewModel.dateOfBirth == null ? '' : DateUtil.formatDDMMYYYY(_viewModel.dateOfBirth!),
    );
  }

  // Validate form inputs and update error states.
  void _validateAndSave() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _dobError = ValidationUtil().validateBirthday(_viewModel.dateOfBirth) != null;
        _genderError = _viewModel.sex == null || _viewModel.sex!.isEmpty;
      });
    } else {
      setState(() {
        _dobError = ValidationUtil().validateBirthday(_viewModel.dateOfBirth) != null;
        _genderError = _viewModel.sex == null || _viewModel.sex!.isEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Birthday & Gender',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: const Color(0xFFD81B60),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This helps us personalize your dating experience.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFAB47BC),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fields marked with * are required.',
              style: theme.textTheme.labelLarge?.copyWith(
                color: const Color(0xFFAB47BC),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            ShakeWidget(
              shake: _dobError,
              child: GestureDetector(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: vm.dateOfBirth ?? DateTime(now.year - 20),
                    firstDate: DateTime(now.year - 120),
                    lastDate: DateTime(now.year - 18),
                  );
                  if (picked != null) {
                    setState(() {
                      vm.dateOfBirth = picked;
                      _dobController.text = DateUtil.formatDDMMYYYY(picked);
                    });
                  }
                },
                child: AbsorbPointer(
                  child: AppTextField(
                    labelText: 'Birthday *',
                    labelStyle: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFBA68C8),
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon: Icons.cake_rounded,
                    prefixIconColor: const Color(0xFFD81B60),
                    controller: _dobController,
                    validator: (v) => ValidationUtil().validateBirthday(vm.dateOfBirth),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF424242),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ShakeWidget(
              shake: _genderError,
              child: ProfileOptionSelector(
                options: sexOptions,
                selectedValue: vm.sex,
                onChanged: (value, selected) {
                  if (selected) {
                    setState(() {
                      vm.sex = value;
                      _genderError = false;
                    });
                  }
                },
                labelText: 'Gender *',
                labelStyle: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFBA68C8),
                  fontWeight: FontWeight.w600,
                ),
                scrollable: false,
              ),
            ),
            const SizedBox(height: 32),
            SetupProfileButton(
              text: 'Next',
              onPressed: () {
                _validateAndSave();
                if (!_dobError && !_genderError) {
                  vm.nextStep();
                } else if (_genderError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select your gender')),
                  );
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