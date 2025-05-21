// lib/presentation/auth/setup_profile/steps/step2_dob_gender_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/utils/date_util.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../setup_profile_viewmodel.dart';

class Step2DobGenderForm extends StatefulWidget {
  const Step2DobGenderForm({super.key});

  @override
  State<Step2DobGenderForm> createState() => _Step2DobGenderFormState();
}

class _Step2DobGenderFormState extends State<Step2DobGenderForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    _dobController = TextEditingController(
      text: vm.dateOfBirth == null
          ? ""
          : DateUtil.formatDDMMYYYY(vm.dateOfBirth!),
    );
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context);
    final theme = Theme.of(context);

    final genders = [
      {'label': 'Male', 'icon': Icons.male, 'value': 'male'},
      {'label': 'Female', 'icon': Icons.female, 'value': 'female'},
    ];

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
                "Your Birthday & Gender",
                style: theme.textTheme.displayMedium?.copyWith(
                  fontFamily: AppTheme.lightTheme.textTheme.displayMedium?.fontFamily,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 6),

            Align(
              alignment: Alignment.center,
              child: Text(
                "Your birthday and gender help us personalize your dating experience.",
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
            GestureDetector(
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
                  labelText: "Birthday *",
                  prefixIcon: Icons.cake_rounded,
                  prefixIconColor: theme.colorScheme.primary,
                  controller: _dobController,
                  validator: (v) =>
                      ValidationUtil().validateBirthday(vm.dateOfBirth),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Gender *",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: genders.map((g) {
                  final isSelected = vm.sex == g['value'];
                  final isMale = g['value'] == 'male';
                  final selectedColor = isMale ? Colors.blue : Colors.pinkAccent;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            g['icon'] as IconData,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(g['label'] as String),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: isSelected ? selectedColor : Colors.yellowAccent.shade200,
                      onSelected: (_) => setState(() => vm.sex = g['value'] as String),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),
            AppButton(
              text: "Next",
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  vm.nextStep();
                }
              },
              width: double.infinity,
              height: 52,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary
                ],
              ),
              textStyle: theme.textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
