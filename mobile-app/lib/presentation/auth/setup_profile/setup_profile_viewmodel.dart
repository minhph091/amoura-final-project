import 'package:flutter/material.dart';

class SetupProfileViewModel extends ChangeNotifier {
  int currentStep = 0;
  final int totalSteps = 2; // Sẽ tăng lên 10 sau

  // Step 1: Name
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  // Step 2: DoB & Gender
  final dateOfBirthController = TextEditingController();
  String? gender;

  void setGender(String? value) {
    gender = value;
    notifyListeners();
  }

  void nextStep() {
    if (currentStep < totalSteps - 1) {
      currentStep++;
      notifyListeners();
    } else {
      // Đăng ký hoàn tất, chuyển vào Home (bổ sung logic backend khi đủ 10 bước)
    }
  }

  void skipStep() {
    nextStep();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }
}