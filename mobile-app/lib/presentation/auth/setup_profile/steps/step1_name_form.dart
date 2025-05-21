// lib/presentation/auth/setup_profile/steps/step1_name_form.dart

import 'package:flutter/material.dart';
import '../setup_profile_viewmodel.dart';
import '../../../shared/widgets/app_text_field.dart';

class Step1NameForm extends StatelessWidget {
  final SetupProfileViewModel viewModel;
  const Step1NameForm({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          controller: viewModel.firstNameController,
          labelText: "First Name",
          hintText: "Enter your first name",
          suffixIcon: const Icon(Icons.badge_outlined),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please enter your first name';
            return null;
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: viewModel.lastNameController,
          labelText: "Last Name",
          hintText: "Enter your last name",
          suffixIcon: const Icon(Icons.badge_outlined),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please enter your last name';
            return null;
          },
        ),
      ],
    );
  }
}