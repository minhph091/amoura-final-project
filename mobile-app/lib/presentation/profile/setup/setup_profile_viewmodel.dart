// lib/presentation/profile/setup/setup_profile_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/update_profile_usecase.dart';
import '../../../core/utils/date_util.dart';
import '../../../core/utils/validation_util.dart';
import 'stepmodel/base_step_viewmodel.dart';
import 'stepmodel/step1_viewmodel.dart';
import 'stepmodel/step2_viewmodel.dart';
import 'stepmodel/step3_viewmodel.dart';
import 'stepmodel/step4_viewmodel.dart';
import 'stepmodel/step5_viewmodel.dart';
import 'stepmodel/step6_viewmodel.dart';
import 'stepmodel/step7_viewmodel.dart';
import 'stepmodel/step8_viewmodel.dart'; // Add this import
import '../../../core/services/setup_profile_service.dart';

class SetupProfileViewModel extends ChangeNotifier {
  final RegisterUseCase _registerUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final SetupProfileService _setupProfileService;
  String? sessionToken;
  int currentStep = 0;
  final int totalSteps = 10;
  final PageController pageController = PageController();

  Map<String, dynamic> profileData = {};
  List<BaseStepViewModel> stepViewModels = [];

  // Step 1 - Required
  String? firstName;
  String? lastName;

  // Step 2 - Required
  DateTime? dateOfBirth;
  String? sex;

  // Step 3
  int? orientationId;
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
  int? bodyTypeId;
  String? bodyType;
  int? height;

  // Step 7
  int? jobIndustryId;
  String? jobIndustry;
  int? educationLevelId;
  String? educationLevel;
  bool? dropOut;

  // Step 8
  int? drinkStatusId;
  String? drinkStatus;
  int? smokeStatusId;
  String? smokeStatus;
  List<String>? selectedPets;

  // Step 9 - Required
  List<String>? selectedInterestIds;
  List<String>? selectedLanguageIds;
  bool? interestedInNewLanguage;

  // Step 10
  String? bio;
  List<String>? additionalPhotos;

  bool get showSkip => !stepViewModels.isNotEmpty ? true : !stepViewModels[currentStep].isRequired;

  SetupProfileViewModel(
    this._registerUseCase,
    this._updateProfileUseCase, {
    this.sessionToken,
    SetupProfileService? setupProfileService,
  }) : _setupProfileService = setupProfileService ?? SetupProfileService() {
    stepViewModel();
    _preloadStepData();
  }

  void stepViewModel() {
    stepViewModels = [
      Step1ViewModel(this),
      Step2ViewModel(this),
      Step3ViewModel(this, setupProfileService: _setupProfileService),
      Step4ViewModel(this, setupProfileService: _setupProfileService),
      Step5ViewModel(this),
      Step6ViewModel(this, setupProfileService: _setupProfileService),
      Step7ViewModel(this, setupProfileService: _setupProfileService),
      Step8ViewModel(this, setupProfileService: _setupProfileService), // Add Step 8
      // Add other steps (9-10) later as needed
    ];
    print('Initialized stepViewModels with Step 8.');
  }

  Future<void> _preloadStepData() async {
    final step3ViewModel = stepViewModels[2] as Step3ViewModel;
    final step6ViewModel = stepViewModels[5] as Step6ViewModel;
    final step7ViewModel = stepViewModels[6] as Step7ViewModel;
    final step8ViewModel = stepViewModels[7] as Step8ViewModel; // Reference Step 8
    await Future.wait([
      step3ViewModel.fetchOrientationOptions(null),
      step6ViewModel.fetchBodyTypeOptions(null),
      step7ViewModel.fetchJobEducationOptions(null),
      step8ViewModel.fetchLifestyleOptions(null), // Preload Step 8 data
    ]);
    notifyListeners();
  }

  void setPageContext(BuildContext context) {
    if (currentStep == 2 || currentStep == 5 || currentStep == 7) {
      notifyListeners();
    }
  }

  void nextStep({required BuildContext context}) async {
    if (currentStep < stepViewModels.length) {
      final currentViewModel = stepViewModels[currentStep];
      final error = currentViewModel.validate();
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        return;
      }
      currentViewModel.saveData();
    }

    if (currentStep == 1) {
      if (profileData['firstName'] != null &&
          profileData['lastName'] != null &&
          profileData['dateOfBirth'] != null &&
          profileData['sex'] != null) {
        await _completeRegistration(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all required fields.')),
        );
      }
    } else if (currentStep < totalSteps - 1) {
      currentStep++;
      setPageContext(context);
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      notifyListeners();
    } else if (currentStep == totalSteps - 1) {
      await _updateProfile(context);
    }
  }

  void skipStep({required BuildContext context}) {
    if (currentStep < totalSteps - 1) {
      currentStep++;
      setPageContext(context);
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      notifyListeners();
    } else if (currentStep == totalSteps - 1) {
      _updateProfile(context);
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      currentStep--;
      setPageContext(pageController.position.context.storageContext);
      pageController.animateToPage(
        currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
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
        firstName: profileData['firstName'],
        lastName: profileData['lastName'],
        dateOfBirth: profileData['dateOfBirth'],
        sex: profileData['sex'],
      );
      print('Complete registration response: $response');
      if (response['status'] == 'COMPLETED') {
        currentStep++;
        pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
        notifyListeners();
      } else {
        throw Exception('Failed to complete registration');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to complete registration. Please try again.')),
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
      'orientationId': orientationId,
      'orientation': orientation,
      'avatarPath': avatarPath,
      'coverPath': coverPath,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'locationPreference': locationPreference,
      'bodyTypeId': bodyTypeId,
      'bodyType': bodyType,
      'height': height,
      'jobIndustryId': jobIndustryId,
      'jobIndustry': jobIndustry,
      'educationLevelId': educationLevelId,
      'educationLevel': educationLevel,
      'dropOut': dropOut,
      'drinkStatusId': drinkStatusId,
      'drinkStatus': drinkStatus,
      'smokeStatusId': smokeStatusId,
      'smokeStatus': smokeStatus,
      'petIds': selectedPets, // Match backend field name
      'selectedInterestIds': selectedInterestIds,
      'selectedLanguageIds': selectedLanguageIds,
      'interestedInNewLanguage': interestedInNewLanguage,
      'bio': bio,
      'galleryPhotos': additionalPhotos,
    };
    print('Updating profile with data: $profileData');

    try {
      final response = await _updateProfileUseCase.execute(
        sessionToken: sessionToken!,
        profileData: profileData,
      );
      print('Update profile response: $response');
      if (response['status'] == 'UPDATED') {
        Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile setup complete!')),
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to update profile. Please try again.')),
      );
    }
  }

  String? validateStep8() {
    return null; // Step 8 is optional
  }

  String? validateCurrentStep() {
    switch (currentStep) {
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

  // Getter và setter cho drinkStatus và drinkStatusId
  int? getDrinkStatusId() => drinkStatusId;
  String? getDrinkStatus() => drinkStatus;
  void setDrinkStatusId(int? value) {
    drinkStatusId = value;
    notifyListeners();
  }
  void setDrinkStatus(String? value) {
    drinkStatus = value;
    notifyListeners();
  }

  // Getter và setter cho smokeStatus và smokeStatusId
  int? getSmokeStatusId() => smokeStatusId;
  String? getSmokeStatus() => smokeStatus;
  void setSmokeStatusId(int? value) {
    smokeStatusId = value;
    notifyListeners();
  }
  void setSmokeStatus(String? value) {
    smokeStatus = value;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}