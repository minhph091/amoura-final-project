import 'package:flutter/material.dart';
import '../register_viewmodel.dart';
import '../../../shared/widgets/app_text_field.dart';

class DateOfBirthForm extends StatelessWidget {
  final RegisterViewModel viewModel;

  const DateOfBirthForm({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "DoB & Gender",
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
            controller: viewModel.dateOfBirthController,
            labelText: "What is your birthday?",
            hintText: "DD / MM / YYYY",
            prefixIcon: Icons.calendar_today,
            keyboardType: TextInputType.datetime,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                viewModel.dateOfBirthController.text =
                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
              }
            },
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your date of birth';
              return null;
            },
          ),
          const SizedBox(height: 20),
          const Text(
            "What is your gender?",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              RadioListTile<String>(
                title: const Text("Male"),
                value: "Male",
                groupValue: viewModel.sex,
                onChanged: (value) {
                  viewModel.sex = value;
                  viewModel.notifyListeners();
                },
                activeColor: Colors.pink,
              ),
              RadioListTile<String>(
                title: const Text("Female"),
                value: "Female",
                groupValue: viewModel.sex,
                onChanged: (value) {
                  viewModel.sex = value;
                  viewModel.notifyListeners();
                },
                activeColor: Colors.pink,
              ),
              RadioListTile<String>(
                title: const Text("Non-binary"),
                value: "Non-binary",
                groupValue: viewModel.sex,
                onChanged: (value) {
                  viewModel.sex = value;
                  viewModel.notifyListeners();
                },
                activeColor: Colors.pink,
              ),
              RadioListTile<String>(
                title: const Text("Prefer not to say"),
                value: "Prefer not to say",
                groupValue: viewModel.sex,
                onChanged: (value) {
                  viewModel.sex = value;
                  viewModel.notifyListeners();
                },
                activeColor: Colors.pink,
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (viewModel.dateOfBirthController.text.isNotEmpty &&
                    viewModel.sex != null) {
                  viewModel.completeRegistration(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in all fields")),
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