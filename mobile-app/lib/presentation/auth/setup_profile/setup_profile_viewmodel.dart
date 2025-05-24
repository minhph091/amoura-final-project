// lib/presentation/auth/setup_profile/setup_profile_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../data/remote/auth_service.dart';
import '../../../core/utils/date_util.dart';
import '../../../core/utils/validation_util.dart';

class SetupProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
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
  int? orientationId;
  String? orientation; // Thêm để đồng bộ với giao diện mới

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
  int? bodyTypeId;
  String? bodyType; // Thêm để đồng bộ với giao diện mới
  int? height;

  // Step 7
  int? jobIndustryId;
  String? jobIndustry; // Thêm để đồng bộ với giao diện mới
  int? educationLevelId;
  String? educationLevel; // Thêm để đồng bộ với giao diện mới
  bool? dropOut;

  // Step 8
  int? drinkStatusId;
  String? drinkStatus; // Thêm để đồng bộ với giao diện mới
  int? smokeStatusId;
  String? smokeStatus; // Thêm để đồng bộ với giao diện mới
  List<String>? selectedPets;

  // Step 9 - Required
  List<String>? selectedInterestIds;
  List<String>? selectedLanguageIds;
  bool? interestedInNewLanguage;

  // Step 10
  String? bio;
  List<String> galleryPhotos = [];

  bool get showSkip => !_isStepRequired(currentStep);

  bool _isStepRequired(int step) => [0, 1, 8].contains(step);

  SetupProfileViewModel({this.sessionToken});

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
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void skipStep({required BuildContext context}) {
    if (currentStep < totalSteps - 1) {
      currentStep++;
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      notifyListeners();
    } else if (currentStep == totalSteps - 1) {
      Navigator.pushReplacementNamed(context, '/home');
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
      final response = await _authService.completeRegistration(
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
        throw ApiException(response['message'] ?? 'Failed to complete registration');
      }
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to complete registration. Please try again.')),
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