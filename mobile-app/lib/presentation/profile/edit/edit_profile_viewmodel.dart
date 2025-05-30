import 'package:flutter/material.dart';
import '../../../../core/utils/validation_util.dart';

class EditProfileViewModel extends ChangeNotifier {
  // Profile data
  dynamic profile;

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
    firstName = profile?.firstName;
    lastName = profile?.lastName;
    dateOfBirth = profile?.dateOfBirth;
    sex = profile?.sex;
    orientation = profile?.orientation;

    avatarUrl = profile?.avatarUrl;
    coverUrl = profile?.coverUrl;

    city = profile?.city;
    state = profile?.state;
    country = profile?.country;
    locationPreference = profile?.locationPreference ?? 10;

    bodyType = profile?.bodyType;
    height = profile?.height ?? 170;

    jobIndustry = profile?.jobIndustry;
    educationLevel = profile?.educationLevel;
    dropOut = profile?.dropOut ?? false;

    drinkStatus = profile?.drinkStatus;
    smokeStatus = profile?.smokeStatus;
    selectedPets = profile?.pets?.cast<String>() ?? [];

    selectedLanguageIds = profile?.languages?.cast<String>() ?? [];
    interestedInNewLanguage = profile?.interestedInNewLanguage ?? false;
    selectedInterestIds = profile?.interests?.cast<String>() ?? [];

    bio = profile?.bio;
    existingPhotos = profile?.galleryPhotos?.cast<String>() ?? [];
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

      // In a real app, this would upload images if needed and call the API
      // For now, we simulate success after a delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Update profile object with new values
      profile.firstName = firstName;
      profile.lastName = lastName;
      profile.dateOfBirth = dateOfBirth;
      profile.sex = sex;
      profile.orientation = orientation;

      // Would handle avatar and cover photo uploads here

      profile.city = city;
      profile.state = state;
      profile.country = country;
      profile.locationPreference = locationPreference;

      profile.bodyType = bodyType;
      profile.height = height;

      profile.jobIndustry = jobIndustry;
      profile.educationLevel = educationLevel;
      profile.dropOut = dropOut;

      profile.drinkStatus = drinkStatus;
      profile.smokeStatus = smokeStatus;
      profile.pets = selectedPets;

      profile.languages = selectedLanguageIds;
      profile.interestedInNewLanguage = interestedInNewLanguage;
      profile.interests = selectedInterestIds;

      profile.bio = bio;
      profile.galleryPhotos = [...existingPhotos];

      // Reset state
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