// lib/presentation/auth/setup_profile/setup_profile_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../core/utils/validation_util.dart'; // Utility for form validation

class SetupProfileViewModel extends ChangeNotifier {
  int currentStep = 0; // Current step in the setup process
  final int totalSteps = 10; // Total number of steps
  final PageController pageController = PageController(); // Controller for PageView navigation

  // Step 1 - Required
  String? firstName;
  String? lastName;

  // Step 2 - Required
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

  // Step 9 - Required
  List<int>? selectedInterestIds;
  List<int>? selectedLanguageIds;
  bool? interestedInNewLanguage;

  // Step 10
  String? bio;
  List<String> galleryPhotos = [];

  bool get showSkip => !_isStepRequired(currentStep); // Determine if skip button should be shown

  /// Required steps: Step 0 (Name), Step 1 (Gender, Birthday), Step 9 (Interests)
  bool _isStepRequired(int step) => [0, 1, 8].contains(step);

  void onSkip() {
    // TODO: Show skip dialog, then call nextStep if confirmed
  }

  void nextStep() {
    if (currentStep < totalSteps - 1) {
      currentStep++;
      // Animate to the next page with a smooth transition
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
      // Animate to the previous page with a smooth transition
      pageController.animateToPage(
        currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
      notifyListeners();
    }
  }

  // Validation methods for each required step

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

  /// Validate the current step if it's required
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

  // Helper for step 3: Set orientation
  void setOrientation(int id) {
    orientationId = id;
    notifyListeners();
  }

  // Helper for step 5: Set location preference
  void setLocationPreference(int value) {
    locationPreference = value;
    notifyListeners();
  }

  // Helper for step 7: Set dropout status
  void setDropOut(bool value) {
    dropOut = value;
    notifyListeners();
  }

  // Helpers for step 10: Manage gallery photos
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
    pageController.dispose(); // Dispose PageController to free resources
    super.dispose();
  }
}