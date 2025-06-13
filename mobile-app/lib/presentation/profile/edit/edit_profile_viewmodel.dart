// lib/presentation/profile/edit/edit_profile_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../../core/constants/profile/body_type_constants.dart';
import '../../../../core/constants/profile/job_constants.dart';
import '../../../../core/constants/profile/education_constants.dart';
import '../../../../core/constants/profile/smoke_drink_constants.dart';
import '../../../../core/constants/profile/pet_constants.dart';
import '../../../../core/constants/profile/interest_constants.dart';
import '../../../../core/constants/profile/language_constants.dart';

class EditProfileViewModel extends ChangeNotifier {
  // Profile data received from ProfileService as a Map
  Map<String, dynamic>? profile;

  // Edited data
  String? firstName;
  String? lastName;
  DateTime? dateOfBirth;
  String? sex;
  String? orientation;

  String? avatarPath;
  String? coverPath;
  String? avatarUrl;
  String? coverUrl;

  String? city;
  String? state;
  String? country;
  int? locationPreference;

  String? bodyType;
  int? height;

  String? jobIndustry;
  String? educationLevel;
  bool? dropOut;

  String? drinkStatus;
  String? smokeStatus;
  List<String>? selectedPets;

  List<String>? selectedLanguageIds;
  bool? interestedInNewLanguage;
  List<String>? selectedInterestIds;

  String? bio;
  List<String> additionalPhotos = [];
  List<String> existingPhotos = [];

  // State variables
  bool isLoading = false;
  bool isSaving = false;
  bool hasChanges = false;
  String? error;
  String? successMessage;

  EditProfileViewModel({this.profile}) {
    _initFromProfile();
  }

  void _initFromProfile() {
    // Comment: Initialize the view model's fields from the profile map received from ProfileService
    // This ensures that all fields (e.g., firstName, avatarUrl, bodyType, ...) are loaded for display and editing
    firstName = profile?['firstName'] as String?;
    lastName = profile?['lastName'] as String?;
    dateOfBirth = profile?['dateOfBirth'] != null 
        ? DateTime.tryParse(profile!['dateOfBirth'] as String) 
        : null;
    sex = profile?['sex'] as String?;
    orientation = profile?['orientation'] != null 
        ? (profile!['orientation'] as Map<String, dynamic>)['name'] as String? 
        : null;

    avatarUrl = profile?['avatarUrl'] as String?;
    coverUrl = profile?['coverUrl'] as String?;

    city = profile?['location'] != null 
        ? (profile!['location'] as Map<String, dynamic>)['city'] as String? 
        : null;
    state = profile?['location'] != null 
        ? (profile!['location'] as Map<String, dynamic>)['state'] as String? 
        : null;
    country = profile?['location'] != null 
        ? (profile!['location'] as Map<String, dynamic>)['country'] as String? 
        : null;
    locationPreference = profile?['locationPreference'] as int? ?? 10;

    // Map bodyType name (label) to value (key) for dropdown
    bodyType = profile?['bodyType'] != null
        ? (() {
            final name = (profile!['bodyType'] as Map<String, dynamic>)['name'];
            final found = bodyTypeOptions.where((option) => option['label'] == name);
            return found.isNotEmpty ? found.first['value'] as String? : null;
          })()
        : null;
    height = profile?['height'] as int? ?? 170;

    // Map jobIndustry name (label) to value (key) for dropdown
    jobIndustry = profile?['jobIndustry'] != null
        ? (() {
            final name = (profile!['jobIndustry'] as Map<String, dynamic>)['name'];
            final found = jobOptions.where((option) => option['label'] == name);
            return found.isNotEmpty ? found.first['value'] as String? : null;
          })()
        : null;
    // Map educationLevel name (label) to value (key) for dropdown
    educationLevel = profile?['educationLevel'] != null
        ? (() {
            final name = (profile!['educationLevel'] as Map<String, dynamic>)['name'];
            final found = educationOptions.where((option) => option['label'] == name);
            return found.isNotEmpty ? found.first['value'] as String? : null;
          })()
        : null;
    dropOut = profile?['dropOut'] as bool? ?? false;

    // Map drinkStatus name (label) to value (key) for dropdown
    drinkStatus = profile?['drinkStatus'] != null
        ? (() {
            final name = (profile!['drinkStatus'] as Map<String, dynamic>)['name'];
            final found = drinkOptions.where((option) => option['label'] == name);
            return found.isNotEmpty ? found.first['value'] as String? : null;
          })()
        : null;
    // Map smokeStatus name (label) to value (key) for dropdown
    smokeStatus = profile?['smokeStatus'] != null
        ? (() {
            final name = (profile!['smokeStatus'] as Map<String, dynamic>)['name'];
            final found = smokeOptions.where((option) => option['label'] == name);
            return found.isNotEmpty ? found.first['value'] as String? : null;
          })()
        : null;
    // Map pet name (label) to value (key) for pet selection
    selectedPets = profile?['pets'] != null
        ? (profile!['pets'] as List<dynamic>)
            .map((pet) {
              final name = (pet as Map<String, dynamic>)['name'];
              final found = petOptions.where((option) => option['label'] == name);
              return found.isNotEmpty ? found.first['value'] as String : null;
            })
            .whereType<String>()
            .toList()
        : [];

    // Map interest name (label) to value (key) for interest selection
    selectedInterestIds = profile?['interests'] != null
        ? (profile!['interests'] as List<dynamic>)
            .map((interest) {
              final name = (interest as Map<String, dynamic>)['name'];
              final found = interestOptions.where((option) => option['label'] == name);
              return found.isNotEmpty ? found.first['value'] as String : null;
            })
            .whereType<String>()
            .toList()
        : [];

    // Map language name (label) to value (key) for language selection
    selectedLanguageIds = profile?['languages'] != null
        ? (profile!['languages'] as List<dynamic>)
            .map((lang) {
              final name = (lang as Map<String, dynamic>)['name'];
              final found = languageOptions.where((option) => option['label'] == name);
              return found.isNotEmpty ? found.first['value'] as String : null;
            })
            .whereType<String>()
            .toList()
        : [];

    interestedInNewLanguage = profile?['interestedInNewLanguage'] as bool? ?? false;

    bio = profile?['bio'] as String?;
    existingPhotos = profile?['galleryPhotos'] != null 
        ? (profile!['galleryPhotos'] as List<dynamic>).cast<String>() 
        : [];
  }

  // MARK: Form field validation

  String? validateFirstName(String? value) {
    return ValidationUtil().validateFirstName(value);
  }

  String? validateLastName(String? value) {
    return ValidationUtil().validateLastName(value);
  }

  String? validateDob() {
    return ValidationUtil().validateBirthday(dateOfBirth);
  }

  String? validateGender() {
    if (sex == null || sex!.isEmpty) {
      return 'Please select your gender';
    }
    return null;
  }

  String? validateInterests() {
    if (selectedInterestIds == null || selectedInterestIds!.isEmpty) {
      return 'Please select at least one interest';
    }
    return null;
  }

  // MARK: Update methods

  void updateFirstName(String value) {
    firstName = value;
    hasChanges = true;
    notifyListeners();
  }

  void updateLastName(String value) {
    lastName = value;
    hasChanges = true;
    notifyListeners();
  }

  void updateDateOfBirth(DateTime value) {
    dateOfBirth = value;
    hasChanges = true;
    notifyListeners();
  }

  void updateGender(String value) {
    sex = value;
    hasChanges = true;
    notifyListeners();
  }

  void updateOrientation(String value) {
    orientation = value;
    hasChanges = true;
    notifyListeners();
  }

  void updateAvatar(String path) {
    avatarPath = path;
    hasChanges = true;
    notifyListeners();
  }

  void updateCover(String path) {
    coverPath = path;
    hasChanges = true;
    notifyListeners();
  }

  void updateLocation({String? city, String? state, String? country}) {
    this.city = city ?? this.city;
    this.state = state ?? this.state;
    this.country = country ?? this.country;
    hasChanges = true;
    notifyListeners();
  }

  void updateLocationPreference(int value) {
    locationPreference = value;
    hasChanges = true;
    notifyListeners();
  }

  void updateBodyType(String value) {
    bodyType = value;
    hasChanges = true;
    notifyListeners();
  }

  void updateHeight(int value) {
    height = value;
    hasChanges = true;
    notifyListeners();
  }

  void updateJobIndustry(String value) {
    jobIndustry = value;
    hasChanges = true;
    notifyListeners();
  }

  void updateEducationLevel(String value) {
    educationLevel = value;
    hasChanges = true;
    notifyListeners();
  }

  void updateDropOut(bool value) {
    dropOut = value;
    hasChanges = true;
    notifyListeners();
  }

  void updateDrinkStatus(String value) {
    drinkStatus = value;
    hasChanges = true;
    notifyListeners();
  }

  void updateSmokeStatus(String value) {
    smokeStatus = value;
    hasChanges = true;
    notifyListeners();
  }

  void updatePet(String value, bool selected) {
    selectedPets ??= [];
    if (selected && !selectedPets!.contains(value)) {
      selectedPets!.add(value);
    } else if (!selected && selectedPets!.contains(value)) {
      selectedPets!.remove(value);
    }
    hasChanges = true;
    notifyListeners();
  }

  void updateLanguage(String value, bool selected) {
    selectedLanguageIds ??= [];
    if (selected && !selectedLanguageIds!.contains(value)) {
      selectedLanguageIds!.add(value);
    } else if (!selected && selectedLanguageIds!.contains(value)) {
      selectedLanguageIds!.remove(value);
    }
    hasChanges = true;
    notifyListeners();
  }

  void updateInterestedInNewLanguage(bool value) {
    interestedInNewLanguage = value;
    hasChanges = true;
    notifyListeners();
  }

  void updateInterest(String value, bool selected) {
    selectedInterestIds ??= [];
    if (selected && !selectedInterestIds!.contains(value)) {
      selectedInterestIds!.add(value);
    } else if (!selected && selectedInterestIds!.contains(value)) {
      selectedInterestIds!.remove(value);
    }
    hasChanges = true;
    notifyListeners();
  }

  void updateBio(String value) {
    bio = value;
    hasChanges = true;
    notifyListeners();
  }

  void addPhoto(String path) {
    additionalPhotos.add(path);
    hasChanges = true;
    notifyListeners();
  }

  void removePhoto(String path) {
    additionalPhotos.remove(path);
    hasChanges = true;
    notifyListeners();
  }

  void removeExistingPhoto(String url) {
    existingPhotos.remove(url);
    hasChanges = true;
    notifyListeners();
  }

  // MARK: API methods

  Future<void> saveProfile() async {
    isSaving = true;
    error = null;
    successMessage = null;
    notifyListeners();

    try {
      // Validate required fields
      final firstNameError = validateFirstName(firstName);
      final lastNameError = validateLastName(lastName);
      final dobError = validateDob();
      final genderError = validateGender();
      final interestsError = validateInterests();

      if (firstNameError != null || lastNameError != null || dobError != null ||
          genderError != null || interestsError != null) {
        throw 'Please fill all required fields correctly';
      }

      // Simulate API call for saving profile (to be implemented later)
      // Comment: In a real app, this would send updated data back to the API (e.g., PATCH /profiles/me)
      await Future.delayed(const Duration(milliseconds: 800));

      // Update profile map with new values for local state consistency
      // Comment: Since profile is a Map<String, dynamic>, we update its values using keys to reflect changes
      profile!['firstName'] = firstName;
      profile!['lastName'] = lastName;
      profile!['dateOfBirth'] = dateOfBirth?.toIso8601String();
      profile!['sex'] = sex;
      if (orientation != null) {
        profile!['orientation'] = {'name': orientation};
      } else {
        profile!['orientation'] = null;
      }

      // Would handle avatar and cover photo uploads here

      if (profile!['location'] == null) {
        profile!['location'] = {};
      }
      profile!['location']['city'] = city;
      profile!['location']['state'] = state;
      profile!['location']['country'] = country;
      profile!['locationPreference'] = locationPreference;

      if (bodyType != null) {
        profile!['bodyType'] = {'name': bodyType};
      } else {
        profile!['bodyType'] = null;
      }
      profile!['height'] = height;

      if (jobIndustry != null) {
        profile!['jobIndustry'] = {'name': jobIndustry};
      } else {
        profile!['jobIndustry'] = null;
      }
      if (educationLevel != null) {
        profile!['educationLevel'] = {'name': educationLevel};
      } else {
        profile!['educationLevel'] = null;
      }
      profile!['dropOut'] = dropOut;

      if (drinkStatus != null) {
        profile!['drinkStatus'] = {'name': drinkStatus};
      } else {
        profile!['drinkStatus'] = null;
      }
      if (smokeStatus != null) {
        profile!['smokeStatus'] = {'name': smokeStatus};
      } else {
        profile!['smokeStatus'] = null;
      }
      profile!['pets'] = selectedPets?.map((pet) => {'name': pet}).toList();

      profile!['languages'] = selectedLanguageIds?.map((id) => {'id': id}).toList();
      profile!['interestedInNewLanguage'] = interestedInNewLanguage;
      profile!['interests'] = selectedInterestIds?.map((id) => {'id': id}).toList();

      profile!['bio'] = bio;
      profile!['galleryPhotos'] = [...existingPhotos];

      // Reset state after successful save
      hasChanges = false;
      successMessage = "Profile updated successfully";
    } catch (e) {
      error = e.toString();
      throw error!;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}