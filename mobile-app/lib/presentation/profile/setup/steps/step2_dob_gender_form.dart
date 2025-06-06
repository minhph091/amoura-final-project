import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/date_util.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../shared/widgets/shake_widget.dart';
import '../theme/setup_profile_theme.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../../../../core/constants/profile/sex_constants.dart';
import '../setup_profile_viewmodel.dart';
import '../stepmodel/step2_viewmodel.dart';

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

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    _dobController = TextEditingController(
      text: vm.dateOfBirth == null ? '' : DateUtil.formatDDMMYYYY(vm.dateOfBirth!),
    );
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);

    // Đồng bộ lại cho Step2ViewModel nếu có
    if (vm.stepViewModels.isNotEmpty && vm.stepViewModels[1] is Step2ViewModel) {
      final step2Vm = vm.stepViewModels[1] as Step2ViewModel;
      step2Vm.dateOfBirth = vm.dateOfBirth;
      step2Vm.sex = vm.sex;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _dobError = ValidationUtil().validateBirthday(vm.dateOfBirth) != null;
        _genderError = vm.sex == null || vm.sex!.isEmpty;
      });
    } else {
      setState(() {
        _dobError = ValidationUtil().validateBirthday(vm.dateOfBirth) != null;
        _genderError = vm.sex == null || vm.sex!.isEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Birthday & Gender', style: ProfileTheme.getTitleStyle(context)),
            const SizedBox(height: 6),
            Text('This helps us personalize your dating experience.', style: ProfileTheme.getDescriptionStyle(context)),
            const SizedBox(height: 8),
            Text('Fields marked with * are required.', style: ProfileTheme.getDescriptionStyle(context)),
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
                      // Đồng bộ lại cho Step2ViewModel
                      if (vm.stepViewModels.isNotEmpty && vm.stepViewModels[1] is Step2ViewModel) {
                        final step2Vm = vm.stepViewModels[1] as Step2ViewModel;
                        step2Vm.dateOfBirth = picked;
                      }
                      _dobController.text = DateUtil.formatDDMMYYYY(picked);
                    });
                  }
                },
                child: AbsorbPointer(
                  child: AppTextField(
                    labelText: 'Birthday *',
                    labelStyle: ProfileTheme.getLabelStyle(context),
                    prefixIcon: Icons.cake_rounded,
                    prefixIconColor: ProfileTheme.darkPink,
                    controller: _dobController,
                    validator: (v) => ValidationUtil().validateBirthday(vm.dateOfBirth),
                    style: ProfileTheme.getInputTextStyle(context),
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
                      // Đồng bộ lại cho Step2ViewModel
                      if (vm.stepViewModels.isNotEmpty && vm.stepViewModels[1] is Step2ViewModel) {
                        final step2Vm = vm.stepViewModels[1] as Step2ViewModel;
                        step2Vm.sex = value;
                      }
                      _genderError = false;
                    });
                  }
                },
                labelText: 'Gender *',
                labelStyle: ProfileTheme.getLabelStyle(context),
                scrollable: false,
              ),
            ),
            const SizedBox(height: 32),
            SetupProfileButton(
              text: 'Next',
              onPressed: () {
                _validateAndSave();
                if (!_dobError && !_genderError) {
                  vm.nextStep(context: context);
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