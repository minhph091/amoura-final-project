// lib/presentation/auth/setup_profile/setup_profile_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:amoura/core/utils/validation_util.dart'; // Đảm bảo import đúng
import 'package:amoura/core/utils/date_util.dart'; // Add this import
import '../../../data/remote/auth_service.dart';

class SetupProfileViewModel extends ChangeNotifier {
  int currentStep = 0;
  final int totalSteps = 10;
  String? sessionToken;

  String? firstName;
  String? lastName;
  DateTime? dateOfBirth;
  String? sex;
  int? orientationId;
  String? avatarPath;
  String? coverPath;
  String? city, state, country;
  double? latitude, longitude;
  int? locationPreference;
  int? bodyTypeId;
  int? height;
  int? jobIndustryId;
  int? educationLevelId;
  bool? dropOut;
  int? drinkStatusId;
  int? smokeStatusId;
  List<int>? selectedPetIds;
  List<String>? selectedPets;
  List<String>? selectedInterestIds;
  List<String>? selectedLanguageIds;
  bool? interestedInNewLanguage;
  String? bio;
  List<String> galleryPhotos = [];

  bool get showSkip => !_isStepRequired(currentStep);

  bool _isStepRequired(int step) => [0, 1, 8].contains(step);

  SetupProfileViewModel({this.sessionToken});

  void onSkip() {
    // TODO: Show skip dialog, then call nextStep if confirmed
  }

  Future<void> nextStep(BuildContext context) async {
    if (currentStep < totalSteps - 1) {
      final validationError = validateCurrentStep();
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validationError)));
        return;
      }
      // Gửi dữ liệu đến API cho Step 0 và Step 1
      if (sessionToken != null) {
        try {
          if (currentStep == 0) {
            await AuthService().updateProfileStep(
              sessionToken: sessionToken!,
              step: currentStep,
              data: {'firstName': firstName, 'lastName': lastName},
            );
          } else if (currentStep == 1) {
            await AuthService().updateProfileStep(
              sessionToken: sessionToken!,
              step: currentStep,
              data: {
                'dateOfBirth': dateOfBirth != null ? DateUtil.formatDDMMYYYY(dateOfBirth!) : null,
                'sex': sex,
              },
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save data: $e')));
          return;
        }
      }
      currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
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

  void setOrientation(int id) {
    orientationId = id;
    notifyListeners();
  }

  void setLocationPreference(int value) {
    locationPreference = value;
    notifyListeners();
  }

  void setDropOut(bool value) {
    dropOut = value;
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

  void skipStep() {
    if (currentStep < totalSteps - 1) {
      currentStep++;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}