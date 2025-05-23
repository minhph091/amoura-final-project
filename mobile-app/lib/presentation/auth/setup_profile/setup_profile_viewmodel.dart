// lib/presentation/auth/setup_profile/setup_profile_viewmodel.dart
// ViewModel to manage the state and navigation logic for the setup profile flow.

import 'package:flutter/material.dart';
import '../../../core/utils/validation_util.dart';

class SetupProfileViewModel extends ChangeNotifier {
  int currentStep = 0;
  final int totalSteps = 10;
  final PageController pageController = PageController();

  // Step 1 - Required
  String? firstName;
  String? lastName;

  // Step 2 - Required
  DateTime? dateOfBirth;
  String? sex;

  // Step 3
  String? orientation;

  // Step 4
  String? avatarPath;
  String? coverPath;

  // Step 5
  String? city, state, country;
  double? latitude, longitude;
  int? locationPreference;

  // Step 6
  String? bodyType;
  int? height;

  // Step 7
  String? jobIndustry;
  String? educationLevel;
  bool? dropOut;

  // Step 8
  String? drinkStatus;
  String? smokeStatus;
  List<String>? selectedPets;

  // Step 9 - Required
  List<String>? selectedInterestIds;
  List<String>? selectedLanguageIds;
  bool? interestedInNewLanguage;

  // Step 10
  String? bio;
  List<String> galleryPhotos = [];

  bool get showSkip => !_isStepRequired(currentStep);

  // Check if the current step is required.
  bool _isStepRequired(int step) => [0, 1, 8].contains(step);

  // Handle the skip action for non-required steps.
  void onSkip() {
    // TODO: Show skip dialog, then call nextStep if confirmed
  }

  // Navigate to the next step.
  void nextStep() {
    if (currentStep < totalSteps - 1) {
      currentStep++;
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      notifyListeners();
    }
  }

  // Navigate to the previous step.
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

  // Validate Step 0 (Name).
  String? validateStep0() {
    final firstError = ValidationUtil().validateFirstName(firstName);
    if (firstError != null) return firstError;
    final lastError = ValidationUtil().validateLastName(lastName);
    if (lastError != null) return lastError;
    return null;
  }

  // Validate Step 1 (Date of Birth and Gender).
  String? validateStep1() {
    if (sex == null || sex!.trim().isEmpty) return 'Please select your gender.';
    final dobError = ValidationUtil().validateBirthday(dateOfBirth);
    if (dobError != null) return dobError;
    return null;
  }

  // Validate Step 8 (Interests).
  String? validateStep8() {
    if (selectedInterestIds == null || selectedInterestIds!.isEmpty) {
      return 'Please select at least one interest.';
    }
    return null;
  }

  // Validate the current step based on its requirements.
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

  // Update the location preference value.
  void setLocationPreference(int value) {
    locationPreference = value;
    notifyListeners();
  }

  // Update the dropout status.
  void setDropOut(bool value) {
    dropOut = value;
    notifyListeners();
  }

  // Add a photo to the gallery.
  void addGalleryPhoto(String path) {
    galleryPhotos.add(path);
    notifyListeners();
  }

  // Remove a photo from the gallery.
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