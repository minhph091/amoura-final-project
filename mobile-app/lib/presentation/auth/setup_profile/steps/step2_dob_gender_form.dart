// lib/presentation/auth/setup_profile/steps/step2_dob_gender_form.dart

import 'package:flutter/material.dart';
import '../setup_profile_viewmodel.dart';
import '../../../shared/widgets/app_text_field.dart';

class Step2DobGenderForm extends StatelessWidget {
  final SetupProfileViewModel viewModel;
  const Step2DobGenderForm({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: viewModel.dateOfBirthController,
          labelText: "Birthday",
          hintText: "DD/MM/YYYY",
          suffixIcon: const Icon(Icons.cake_outlined),
          keyboardType: TextInputType.datetime,
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              viewModel.dateOfBirthController.text =
              "${picked.day.toString().padLeft(2, '0')}/"
                  "${picked.month.toString().padLeft(2, '0')}/"
                  "${picked.year}";
            }
          },
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please enter your birthday';
            // Có thể validate format sâu hơn nếu muốn
            return null;
          },
        ),
        const SizedBox(height: 20),
        const Text(
          "Gender",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        RadioListTile<String>(
          title: const Text("Male"),
          value: "male",
          groupValue: viewModel.gender,
          onChanged: viewModel.setGender,
        ),
        RadioListTile<String>(
          title: const Text("Female"),
          value: "female",
          groupValue: viewModel.gender,
          onChanged: viewModel.setGender,
        ),
        RadioListTile<String>(
          title: const Text("Other"),
          value: "other",
          groupValue: viewModel.gender,
          onChanged: viewModel.setGender,
        ),
      ],
    );
  }
}