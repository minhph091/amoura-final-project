import 'package:flutter/material.dart';
import '../register_viewmodel.dart';
import '../../../shared/widgets/app_text_field.dart';

class CompleteRegistrationForm extends StatelessWidget {
  final RegisterViewModel viewModel;

  const CompleteRegistrationForm({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What is your name?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "This information helps others understand you better. Please fill it in accurately.",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: viewModel.firstNameController,
            labelText: "First name",
            prefixIcon: Icons.person,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your first name';
              return null;
            },
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: viewModel.lastNameController,
            labelText: "Last name",
            prefixIcon: Icons.person,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your last name';
              return null;
            },
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (viewModel.firstNameController.text.isNotEmpty &&
                    viewModel.lastNameController.text.isNotEmpty) {
                  viewModel.showDateOfBirthForm = true;
                  viewModel.notifyListeners();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in both fields")),
                  );
                }
              },
              child: const Text("Next"),
            ),
          ),
        ],
      ),
    );
  }
}