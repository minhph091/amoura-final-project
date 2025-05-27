// lib/presentation/auth/setup_profile/setup_profile_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/update_profile_usecase.dart';
import '../../../core/utils/date_util.dart';
import '../../../core/utils/validation_util.dart';

class SetupProfileViewModel extends ChangeNotifier {
  final RegisterUseCase _registerUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  String? sessionToken;
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
  String? city;
  String? state;
  String? country;
  double? latitude;
  double? longitude;
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
  List<String>? additionalPhotos;

  bool get showSkip => !_isStepRequired(currentStep);

  bool _isStepRequired(int step) => [0, 1, 8].contains(step);

  SetupProfileViewModel(this._registerUseCase, this._updateProfileUseCase, {this.sessionToken});

  void nextStep({required BuildContext context}) {
    final error = validateCurrentStep();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    if (currentStep == 1) {
      if (firstName != null && lastName != null && dateOfBirth != null && sex != null) {
        _completeRegistration(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all required fields.')),
        );
      }
    } else if (currentStep < totalSteps - 1) {
      currentStep++;
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      notifyListeners();
    } else if (currentStep == totalSteps - 1) {
      _updateProfile(context);
    }
  }

  void skipStep({required BuildContext context}) {
    if (currentStep < totalSteps - 1) {
      currentStep++;
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      notifyListeners();
    } else if (currentStep == totalSteps - 1) {
      _updateProfile(context);
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


  Future<void> _completeRegistration(BuildContext context) async {
    if (sessionToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid registration session')),
      );
      return;
    }

    try {
      final response = await _registerUseCase.complete(
        sessionToken: sessionToken!,
        firstName: firstName!,
        lastName: lastName!,
        dateOfBirth: DateUtil.formatYYYYMMDD(dateOfBirth!),
        sex: sex!,
      );
      if (response['status'] == 'COMPLETED') {
        currentStep++;
        pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        notifyListeners();
      } else {
        throw Exception('Failed to complete registration');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to complete registration. Please try again.')),
      );
    }
  }

  Future<void> _updateProfile(BuildContext context) async {
    if (sessionToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid session')),
      );
      return;
    }

    final profileData = {
      'orientation': orientation,
      'avatarPath': avatarPath,
      'coverPath': coverPath,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'locationPreference': locationPreference,
      'bodyType': bodyType,
      'height': height,
      'jobIndustry': jobIndustry,
      'educationLevel': educationLevel,
      'dropOut': dropOut,
      'drinkStatus': drinkStatus,
      'smokeStatus': smokeStatus,
      'selectedPets': selectedPets,
      'selectedInterestIds': selectedInterestIds,
      'selectedLanguageIds': selectedLanguageIds,
      'interestedInNewLanguage': interestedInNewLanguage,
      'bio': bio,
      'galleryPhotos': additionalPhotos,
    };

    try {
      final response = await _updateProfileUseCase.execute(
        sessionToken: sessionToken!,
        profileData: profileData,
      );
      if (response['status'] == 'UPDATED') {
        Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile setup complete!')),
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile. Please try again.')),
      );
    }
  }

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

  void setLocationPreference(int value) {
    locationPreference = value;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}