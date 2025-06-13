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
import '../../../../core/constants/profile/orientation_constants.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../domain/usecases/auth/update_profile_usecase.dart';
import '../../../../core/services/profile_service.dart';

class EditProfileViewModel extends ChangeNotifier {
  // Profile data received from ProfileService as a Map
  Map<String, dynamic>? profile;
  Map<String, dynamic>? _originalProfile;

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

  // Options lấy từ API
  Map<String, dynamic>? profileOptions;

  EditProfileViewModel({this.profile}) {
    _initFromProfile();
    if (profile != null) {
      _originalProfile = _deepCopy(profile!);
    }
    // Gọi load options khi khởi tạo
    loadProfileOptions();
  }

  void _initFromProfile() {
    // Lưu id cho orientation
    orientation = profile?['orientation'] != null
        ? (profile!['orientation'] as Map<String, dynamic>)['id']?.toString()
        : null;

    // Lưu id cho bodyType
    bodyType = profile?['bodyType'] != null
        ? (profile!['bodyType'] as Map<String, dynamic>)['id']?.toString()
        : null;
    height = profile?['height'] as int? ?? 170;

    // Lưu id cho jobIndustry
    jobIndustry = profile?['jobIndustry'] != null
        ? (profile!['jobIndustry'] as Map<String, dynamic>)['id']?.toString()
        : null;
    // Lưu id cho educationLevel
    educationLevel = profile?['educationLevel'] != null
        ? (profile!['educationLevel'] as Map<String, dynamic>)['id']?.toString()
        : null;
    dropOut = profile?['dropOut'] as bool? ?? false;

    // Lưu id cho drinkStatus
    drinkStatus = profile?['drinkStatus'] != null
        ? (profile!['drinkStatus'] as Map<String, dynamic>)['id']?.toString()
        : null;
    // Lưu id cho smokeStatus
    smokeStatus = profile?['smokeStatus'] != null
        ? (profile!['smokeStatus'] as Map<String, dynamic>)['id']?.toString()
        : null;
    // Lưu id cho pets
    selectedPets = profile?['pets'] != null
        ? (profile!['pets'] as List<dynamic>)
            .map((pet) => (pet as Map<String, dynamic>)['id']?.toString())
            .whereType<String>()
            .toList()
        : [];

    // Lưu id cho interests
    selectedInterestIds = profile?['interests'] != null
        ? (profile!['interests'] as List<dynamic>)
            .map((interest) => (interest as Map<String, dynamic>)['id']?.toString())
            .whereType<String>()
            .toList()
        : [];

    // Lưu id cho languages
    selectedLanguageIds = profile?['languages'] != null
        ? (profile!['languages'] as List<dynamic>)
            .map((lang) => (lang as Map<String, dynamic>)['id']?.toString())
            .whereType<String>()
            .toList()
        : [];

    // Các trường còn lại giữ nguyên
    firstName = profile?['firstName'] as String?;
    lastName = profile?['lastName'] as String?;
    dateOfBirth = profile?['dateOfBirth'] != null 
        ? DateTime.tryParse(profile!['dateOfBirth'] as String) 
        : null;
    sex = profile?['sex'] as String?;
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

      // Comment: Lấy ID trực tiếp từ API response thay vì map từ value
      List<int>? petIdList = profile?['pets'] != null
          ? (profile!['pets'] as List<dynamic>)
              .map((pet) => (pet as Map<String, dynamic>)['id'] as int)
              .toList()
          : [];

      List<int>? interestIdList = profile?['interests'] != null
          ? (profile!['interests'] as List<dynamic>)
              .map((interest) => (interest as Map<String, dynamic>)['id'] as int)
              .toList()
          : [];

      List<int>? languageIdList = profile?['languages'] != null
          ? (profile!['languages'] as List<dynamic>)
              .map((lang) => (lang as Map<String, dynamic>)['id'] as int)
              .toList()
          : [];

      // Comment: Lấy ID trực tiếp từ API response cho các trường đơn lẻ
      int? bodyTypeId = profile?['bodyType'] != null
          ? (profile!['bodyType'] as Map<String, dynamic>)['id'] as int?
          : null;

      int? jobIndustryId = profile?['jobIndustry'] != null
          ? (profile!['jobIndustry'] as Map<String, dynamic>)['id'] as int?
          : null;

      int? educationLevelId = profile?['educationLevel'] != null
          ? (profile!['educationLevel'] as Map<String, dynamic>)['id'] as int?
          : null;

      int? orientationId = profile?['orientation'] != null
          ? (profile!['orientation'] as Map<String, dynamic>)['id'] as int?
          : null;

      int? drinkStatusId = profile?['drinkStatus'] != null
          ? (profile!['drinkStatus'] as Map<String, dynamic>)['id'] as int?
          : null;

      int? smokeStatusId = profile?['smokeStatus'] != null
          ? (profile!['smokeStatus'] as Map<String, dynamic>)['id'] as int?
          : null;

      // Chuẩn hóa dữ liệu gửi lên backend
      final Map<String, dynamic> profileData = {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'sex': sex,
        'orientationId': orientationId,
        'city': city,
        'state': state,
        'country': country,
        'locationPreference': locationPreference,
        'bodyTypeId': bodyTypeId,
        'height': height,
        'jobIndustryId': jobIndustryId,
        'educationLevelId': educationLevelId,
        'dropOut': dropOut,
        'drinkStatusId': drinkStatusId,
        'smokeStatusId': smokeStatusId,
        'petIds': petIdList,
        'interestIds': interestIdList,
        'languageIds': languageIdList,
        'interestedInNewLanguage': interestedInNewLanguage,
        'bio': bio,
        'galleryPhotos': existingPhotos,
      };
      profileData.removeWhere((key, value) => value == null || (value is List && value.isEmpty));

      // Lấy access token
      final authService = GetIt.I<AuthService>();
      final accessToken = await authService.getAccessToken();
      if (accessToken == null) throw 'Authentication required. Please log in again.';

      // Gọi usecase để update profile
      final updateProfileUseCase = GetIt.I<UpdateProfileUseCase>();
      final response = await updateProfileUseCase.execute(
        sessionToken: accessToken,
        profileData: profileData,
      );

      // Cập nhật lại profile local với dữ liệu mới trả về (nếu có)
      if (response != null) {
        profile = Map<String, dynamic>.from(response);
        _originalProfile = _deepCopy(profile!);
        _initFromProfile();
      }

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

  // Hàm deep copy cho Map<String, dynamic>
  Map<String, dynamic> _deepCopy(Map<String, dynamic> source) {
    return Map<String, dynamic>.from(source.map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(key, _deepCopy(value));
      } else if (value is List) {
        return MapEntry(key, value.map((e) => e is Map<String, dynamic> ? _deepCopy(e) : e).toList());
      } else {
        return MapEntry(key, value);
      }
    }));
  }

  // Hàm khôi phục lại dữ liệu gốc
  void resetToOriginal() {
    if (_originalProfile != null) {
      profile = _deepCopy(_originalProfile!);
      _initFromProfile();
      hasChanges = false;
      notifyListeners();
    }
  }

  // Hàm load options từ API
  Future<void> loadProfileOptions() async {
    try {
      final profileService = GetIt.I<ProfileService>();
      profileOptions = await profileService.getProfileOptions();
      notifyListeners();
    } catch (e) {
      print('Error loading profile options: $e');
    }
  }

  // Helper: Chuẩn hóa options từ API để tránh lỗi null hoặc sai kiểu
  List<Map<String, dynamic>> safeOptions(List? raw) {
    if (raw == null) return [];
    return raw.map<Map<String, dynamic>>((e) => {
      'value': (e['value'] ?? e['id'] ?? '').toString(),
      'label': (e['label'] ?? e['name'] ?? 'Unknown').toString(),
      if (e['icon'] != null) 'icon': e['icon'],
      if (e['color'] != null) 'color': e['color'],
    }).toList();
  }
}