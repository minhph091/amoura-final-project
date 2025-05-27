// lib/presentation/auth/setup_profile/steps/step1_name_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../shared/widgets/shake_widget.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../setup_profile_viewmodel.dart';
import '../theme/setup_profile_theme.dart';

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

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    _firstNameCtrl = TextEditingController(text: vm.firstName ?? "");
    _lastNameCtrl = TextEditingController(text: vm.lastName ?? "");
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your Name", style: SetupProfileTheme.getTitleStyle(context)),
            const SizedBox(height: 6),
            Text("This name will be visible to everyone.", style: SetupProfileTheme.getDescriptionStyle(context)),
            const SizedBox(height: 8),
            Text("Fields marked with * are required.", style: SetupProfileTheme.getDescriptionStyle(context)),
            const SizedBox(height: 24),
            ShakeWidget(
              shake: _firstNameError,
              child: AppTextField(
                controller: _firstNameCtrl,
                labelText: "First Name *",
                labelStyle: SetupProfileTheme.getLabelStyle(context),
                prefixIcon: Icons.person,
                prefixIconColor: SetupProfileTheme.darkPink,
                maxLength: 50,
                validator: (v) => ValidationUtil().validateFirstName(v),
                onSaved: (v) => vm.firstName = v?.trim(),
                style: SetupProfileTheme.getInputTextStyle(context),
              ),
            ),
            const SizedBox(height: 18),
            ShakeWidget(
              shake: _lastNameError,
              child: AppTextField(
                controller: _lastNameCtrl,
                labelText: "Last Name *",
                labelStyle: SetupProfileTheme.getLabelStyle(context),
                prefixIcon: Icons.badge,
                prefixIconColor: SetupProfileTheme.darkPink,
                maxLength: 50,
                validator: (v) => ValidationUtil().validateLastName(v),
                onSaved: (v) => vm.lastName = v?.trim(),
                style: SetupProfileTheme.getInputTextStyle(context),
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