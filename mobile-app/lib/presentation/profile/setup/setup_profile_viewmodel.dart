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
import 'stepmodel/step8_viewmodel.dart';
import 'stepmodel/step9_viewmodel.dart';
import 'stepmodel/step10_viewmodel.dart';
import '../../../core/services/setup_profile_service.dart';
import '../../../core/services/auth_service.dart';

class SetupProfileViewModel extends ChangeNotifier {
  final RegisterUseCase _registerUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final SetupProfileService _setupProfileService;
  final AuthService _authService;
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

  bool get showSkip => !stepViewModels.isEmpty ? !stepViewModels[currentStep].isRequired : true;

  SetupProfileViewModel(
    this._registerUseCase,
    this._updateProfileUseCase, {
    this.sessionToken,
    SetupProfileService? setupProfileService,
    AuthService? authService,
  })  : _setupProfileService = setupProfileService ?? SetupProfileService(),
        _authService = authService ?? GetIt.I<AuthService>() {
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
      Step6ViewModel(parent: this, setupProfileService: _setupProfileService),
      Step7ViewModel(this, setupProfileService: _setupProfileService),
      Step8ViewModel(this, setupProfileService: _setupProfileService),
      Step9ViewModel(this, setupProfileService: _setupProfileService),
      Step10ViewModel(this, setupProfileService: _setupProfileService),
    ];
    print('Initialized stepViewModels with Step 10.');
  }

  Future<void> _preloadStepData() async {
    final step3ViewModel = stepViewModels[2] as Step3ViewModel;
    final step6ViewModel = stepViewModels[5] as Step6ViewModel;
    final step7ViewModel = stepViewModels[6] as Step7ViewModel;
    final step8ViewModel = stepViewModels[7] as Step8ViewModel;
    final step9ViewModel = stepViewModels[8] as Step9ViewModel;
    await Future.wait(<Future<void>>[
      step3ViewModel.fetchOrientationOptions(null),
      step6ViewModel.fetchBodyTypeOptions(null),
      step7ViewModel.fetchJobEducationOptions(null),
      step8ViewModel.fetchLifestyleOptions(null),
      step9ViewModel.fetchInterestsLanguagesOptions(null),
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
      if (currentStep == 2) {
        await _updateProfileStep(context, step: 3);
      } else if (currentStep == 4) {
        await _updateProfileStep(context, step: 5);
      } else if (currentStep == 5) {
        await _updateProfileStep(context, step: 6);
      } else if (currentStep == 6) {
        await _updateProfileStep(context, step: 7);
      } else if (currentStep == 7) {
        await _updateProfileStep(context, step: 8);
      } else if (currentStep == 8) {
        await _updateProfileStep(context, step: 9);
      }
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
      final step10ViewModel = stepViewModels[9] as Step10ViewModel;
      step10ViewModel.saveData();
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
        if (response['authResponse'] != null && response['authResponse']['accessToken'] != null) {
          sessionToken = response['authResponse']['accessToken'];
          print('Updated sessionToken with accessToken: ${sessionToken!.substring(0, 10)}...');
        }
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

  // Update profile for specific steps (Step 3, 5, 6, 7, 8, 9) with API
  Future<void> _updateProfileStep(BuildContext context, {required int step}) async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication required. Please log in again.')),
      );
      return;
    }

    Map<String, dynamic> stepData = {};
    if (step == 3) {
      if (orientationId == null || orientation == null) {
        print('Skipping updateProfileStep because orientationId or orientation is null');
        return;
      }
      stepData = {
        'orientationId': orientationId,
        'orientation': orientation,
      };
    } else if (step == 5) {
      stepData = {
        'location': {
          'city': profileData['city'],
          'state': profileData['state'],
          'country': profileData['country'],
          'latitude': profileData['latitude'],
          'longitude': profileData['longitude'],
        },
        'locationPreference': profileData['locationPreference'], // Use the latest value from profileData
      };
      print('Prepared step 5 data for API: $stepData'); // Log data before sending to API
    } else if (step == 6) {
      final step6ViewModel = stepViewModels[5] as Step6ViewModel;
      stepData = {
        'bodyTypeId': step6ViewModel.bodyTypeId != null ? int.tryParse(step6ViewModel.bodyTypeId!) : null,
        'height': step6ViewModel.height,
      };
      if (stepData['bodyTypeId'] == null && stepData['height'] == null) {
        print('Skipping updateProfileStep because all fields are null');
        return;
      }
    } else if (step == 7) {
      final step7ViewModel = stepViewModels[6] as Step7ViewModel;
      stepData = {
        'jobIndustryId': step7ViewModel.jobIndustryId != null ? int.tryParse(step7ViewModel.jobIndustryId!) : null,
        'educationLevelId': step7ViewModel.educationLevelId != null ? int.tryParse(step7ViewModel.educationLevelId!) : null,
        'dropOut': step7ViewModel.dropOut,
      };
      if (stepData['jobIndustryId'] == null && stepData['educationLevelId'] == null && stepData['dropOut'] == null) {
        print('Skipping updateProfileStep because all fields are null');
        return;
      }
    } else if (step == 8) {
      final step8ViewModel = stepViewModels[7] as Step8ViewModel;
      stepData = {
        'drinkStatusId': step8ViewModel.drinkStatusId != null ? int.tryParse(step8ViewModel.drinkStatusId!) : null,
        'smokeStatusId': step8ViewModel.smokeStatusId != null ? int.tryParse(step8ViewModel.drinkStatusId!) : null,
        // [API Integration] Convert selectedPets from List<String> to List<int> to match backend (List<Long>)
        'petIds': step8ViewModel.selectedPets?.map((id) => int.parse(id)).toList() ?? [],
      };
      stepData.removeWhere((key, value) => value == null || (value is List && value.isEmpty));
      if (stepData.isEmpty) {
        print('Skipping updateProfileStep because all fields are null or empty');
        return;
      }
    } else if (step == 9) {
      final step9ViewModel = stepViewModels[8] as Step9ViewModel;
      // [API Integration - Debug] Log raw selectedLanguageIds to verify data from UI before processing
      print('Raw selectedInterestIds in Step 9: ${step9ViewModel.selectedInterestIds}');
      print('Raw selectedLanguageIds in Step 9: ${step9ViewModel.selectedLanguageIds}');
      print('Raw interestedInNewLanguage in Step 9: ${step9ViewModel.interestedInNewLanguage}');
      stepData = {
        // [API Integration] Convert selectedInterestIds from List<String> to List<int> to match backend (List<Long>)
        'interestIds': step9ViewModel.selectedInterestIds?.map((id) {
          try {
            return int.parse(id);
          } catch (e) {
            print('Error parsing interestId $id: $e');
            return null;
          }
        }).where((id) => id != null).toList() ?? [],
        // [API Integration] Convert selectedLanguageIds from List<String> to List<int> to match backend (List<Long>)
        'languageIds': step9ViewModel.selectedLanguageIds?.map((id) {
          try {
            return int.parse(id);
          } catch (e) {
            print('Error parsing languageId $id: $e');
            return null;
          }
        }).where((id) => id != null).toList() ?? [],
        'interestedInNewLanguage': step9ViewModel.interestedInNewLanguage,
      };
      // [API Integration - Debug] Log parsed stepData to verify data before sending to API
      print('Parsed stepData for Step 9 before API call: $stepData');
      stepData.removeWhere((key, value) => value == null || (value is List && value.isEmpty));
      if (stepData.isEmpty) {
        print('Skipping updateProfileStep because all fields are null or empty');
        return;
      }
    }

    print('Updating profile step $step with data: $stepData');

    try {
      // [API Integration] Send PATCH request to update profile step
      // - Endpoint: /profiles/me
      // - Method: PATCH
      // - Headers: Authorization Bearer <accessToken>
      // - Body: stepData (contains the latest data for the step)
      print('Sending PATCH request to /profiles/me with accessToken: ${accessToken.substring(0, 10)}...');
      final response = await _updateProfileUseCase.execute(
        sessionToken: accessToken,
        profileData: stepData,
      );
      print('Update profile step $step response: $response');
      // [API Response Validation] Check if update was successful based on status code or response structure
      if (response is Map<String, dynamic> && (response['status'] == 'UPDATED' || response['statusCode'] == 200)) {
        print('Profile step $step updated successfully');
      } else {
        throw Exception('Could not update profile step $step: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error updating profile step $step: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile step $step: $e')),
      );
    }
  }

  Future<void> _updateProfile(BuildContext context) async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication required. Please log in again.')),
      );
      return;
    }
    final step10ViewModel = stepViewModels[9] as Step10ViewModel;
    step10ViewModel.saveData();

    final profileData = {
      'orientationId': orientationId,
      'orientation': orientation,
      'avatarPath': avatarPath,
      'coverPath': coverPath ?? (additionalPhotos?.isNotEmpty ?? false ? additionalPhotos!.first : null),
      'location': {
        'city': city,
        'state': state,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'locationPreference': locationPreference,
      },
      'bodyTypeId': bodyTypeId,
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
      // [API Integration] Convert selectedPets from List<String> to List<int> to match backend (List<Long>)
      'petIds': selectedPets?.map((id) => int.parse(id)).toList() ?? [],
      // [API Integration] Convert selectedInterestIds from List<String> to List<int> to match backend (List<Long>)
      'interestIds': selectedInterestIds?.map((id) => int.parse(id)).toList() ?? [],
      // [API Integration] Convert selectedLanguageIds from List<String> to List<int> to match backend (List<Long>)
      'languageIds': selectedLanguageIds?.map((id) => int.parse(id)).toList() ?? [],
      'interestedInNewLanguage': interestedInNewLanguage,
      'bio': bio,
      'galleryPhotos': additionalPhotos ?? [],
    };

    profileData.removeWhere((key, value) => value == null || (value is List && value.isEmpty));

    print('Updating profile with data: $profileData');

    try {
      // [API Integration] Send final PATCH request to update entire profile
      // - Endpoint: /profiles/me
      // - Method: PATCH
      // - Headers: Authorization Bearer <accessToken>
      // - Body: profileData
      final response = await _updateProfileUseCase.execute(
        sessionToken: accessToken,
        profileData: profileData,
      );
      print('Update profile response: $response');
      // [API Response Validation] Check if update was successful
      if (response['status'] == 'UPDATED') {
        Navigator.pushReplacementNamed(context, '/mainNavigator');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile setup complete!')),
        );
      } else {
        throw Exception('Failed to update profile: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
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
    profileData['locationPreference'] = value; // Update profileData with slider value
    notifyListeners();
    print('Set location preference to: $value km'); // Log to confirm slider update
  }

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