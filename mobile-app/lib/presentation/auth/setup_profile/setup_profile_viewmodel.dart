// lib/presentation/auth/setup_profile/setup_profile_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../core/utils/validation_util.dart';

class SetupProfileViewModel extends ChangeNotifier {
  int currentStep = 0;
  final int totalSteps = 10;
  final PageController pageController = PageController();

  // Step 1 - Bắt buộc
  String? firstName;
  String? lastName;

  // Step 2 - Bắt buộc
  DateTime? dateOfBirth;
  String? sex;

  // Step 3
  int? orientationId;

  // Step 4
  String? avatarPath;
  String? coverPath;

  // Step 5
  String? city, state, country;
  double? latitude, longitude;
  int? locationPreference;

  // Step 6
  int? bodyTypeId;
  int? height;

  // Step 7
  int? jobIndustryId;
  int? educationLevelId;
  bool? dropOut;

  // Step 8
  int? drinkStatusId;
  int? smokeStatusId;
  List<int>? selectedPetIds;

  // Step 9 - Bắt buộc
  List<int>? selectedInterestIds;
  List<int>? selectedLanguageIds;
  bool? interestedInNewLanguage;

  // Step 10
  String? bio;
  List<String> galleryPhotos = [];

  bool get showSkip => !_isStepRequired(currentStep);

  /// Các bước bắt buộc: Step 0 (Tên), Step 1 (Giới tính, Ngày sinh), Step 8 (Sở thích)
  bool _isStepRequired(int step) => [0, 1, 8].contains(step);

  void onSkip() {
    // TODO: Show skip dialog, then nextStep if confirm
  }

  void nextStep() {
    if (currentStep < totalSteps - 1) {
      currentStep++;
      pageController.animateToPage(
        currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
      notifyListeners();
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      currentStep--;
      pageController.animateToPage(
        currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
      notifyListeners();
    }
  }

  // Validation cho từng bước

  String? validateStep0() {
    final firstError = ValidationUtil().validateFirstName(firstName);
    if (firstError != null) return firstError;
    final lastError = ValidationUtil().validateLastName(lastName);
    if (lastError != null) return lastError;
    return null;
  }

  String? validateStep1() {
    if (sex == null || sex!.trim().isEmpty) return 'Please select your gender.';
    final dobError = ValidationUtil().validateBirthday(dateOfBirth);
    if (dobError != null) return dobError;
    return null;
  }

  String? validateStep8() {
    if (selectedInterestIds == null || selectedInterestIds!.isEmpty) {
      return 'Please select at least one interest.';
    }
    return null;
  }

  /// Tổng hợp kiểm tra toàn bộ các bước bắt buộc
  String? validateCurrentStep() {
    switch (currentStep) {
      case 0:
        return validateStep0();
      case 1:
        return validateStep1();
      case 8:
        return validateStep8();
      default:
        return null;
    }
  }

  // Helper cho step 3
  void setOrientation(int id) {
    orientationId = id;
    notifyListeners();
  }

  // Helper cho step 5
  void setLocationPreference(int value) {
    locationPreference = value;
    notifyListeners();
  }

  // Helper cho step 7
  void setDropOut(bool value) {
    dropOut = value;
    notifyListeners();
  }

  // Helper cho step 10
  void addGalleryPhoto(String path) {
    galleryPhotos.add(path);
    notifyListeners();
  }

  void removeGalleryPhoto(String path) {
    galleryPhotos.remove(path);
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
