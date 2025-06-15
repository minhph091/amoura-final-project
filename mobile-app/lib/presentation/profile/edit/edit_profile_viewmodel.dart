// lib/presentation/profile/edit/edit_profile_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../../core/utils/validation_util.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../domain/usecases/auth/update_profile_usecase.dart';
import '../../../../core/services/profile_service.dart';
import '../../../../domain/usecases/user/update_user_usecase.dart';
import '../../../../data/remote/profile_api.dart';
import 'dart:io';

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
  List<int> removedHighlightIds = [];

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

  void removeExistingPhoto(int photoId) {
    removedHighlightIds.add(photoId);
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

      // Lấy access token
      final authService = GetIt.I<AuthService>();
      final accessToken = await authService.getAccessToken();
      if (accessToken == null) throw 'Authentication required. Please log in again.';

      final profileApi = GetIt.I<ProfileApi>();

      // 1. Upload avatar nếu có thay đổi
      if (avatarPath != null) {
        // Kiểm tra định dạng file
        if (!await _isValidImageFile(avatarPath!)) {
          throw 'Invalid image file format for avatar';
        }
        final url = await profileApi.uploadAvatar(avatarPath!);
        avatarUrl = url;
        avatarPath = null;
      }

      // 2. Upload cover nếu có thay đổi
      if (coverPath != null) {
        // Kiểm tra định dạng file
        if (!await _isValidImageFile(coverPath!)) {
          throw 'Invalid image file format for cover';
        }
        final url = await profileApi.uploadCover(coverPath!);
        coverUrl = url;
        coverPath = null;
      }

      // 3. Xóa highlight nếu có
      for (final id in removedHighlightIds) {
        await profileApi.deleteHighlight(id);
      }
      removedHighlightIds.clear();

      // 4. Upload highlight mới nếu có
      for (final path in additionalPhotos) {
        if (!await _isValidImageFile(path)) {
          throw 'Invalid image file format for highlight';
        }
        await profileApi.uploadHighlight(path);
      }
      await reloadProfile();
      additionalPhotos.clear();

      // Chỉ gửi firstName, lastName vào /user
      final Map<String, dynamic> userData = {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
      };

      // Chuyển các trường id sang int
      int? bodyTypeId = bodyType != null ? int.tryParse(bodyType!) : null;
      int? jobIndustryId = jobIndustry != null ? int.tryParse(jobIndustry!) : null;
      int? educationLevelId = educationLevel != null ? int.tryParse(educationLevel!) : null;
      int? orientationId = orientation != null ? int.tryParse(orientation!) : null;
      int? drinkStatusId = drinkStatus != null ? int.tryParse(drinkStatus!) : null;
      int? smokeStatusId = smokeStatus != null ? int.tryParse(smokeStatus!) : null;
      List<int> petIdList = selectedPets?.map((id) => int.tryParse(id)).whereType<int>().toList() ?? [];
      List<int> interestIdList = selectedInterestIds?.map((id) => int.tryParse(id)).whereType<int>().toList() ?? [];
      List<int> languageIdList = selectedLanguageIds?.map((id) => int.tryParse(id)).whereType<int>().toList() ?? [];

      final Map<String, dynamic> profileData = {
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
      };
      profileData.removeWhere((key, value) => value == null || (value is List && value.isEmpty));

      // Gọi update user nếu có thay đổi
      if (userData.isNotEmpty) {
        final updateUserUseCase = GetIt.I<UpdateUserUseCase>();
        await updateUserUseCase.execute(userData: userData);
      }

      // Gọi update profile nếu có thay đổi
      if (profileData.isNotEmpty) {
        final updateProfileUseCase = GetIt.I<UpdateProfileUseCase>();
        await updateProfileUseCase.execute(
          sessionToken: accessToken,
          profileData: profileData,
        );
      }

      // Sau khi update, load lại profile để đồng bộ dữ liệu mới nhất
      final profileService = GetIt.I<ProfileService>();
      profile = await profileService.getProfile();
      _originalProfile = _deepCopy(profile!);
      _initFromProfile();
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

  Future<void> uploadAvatar(String filePath) async {
    final profileApi = GetIt.I<ProfileApi>();
    try {
      isLoading = true;
      notifyListeners();
      if (avatarUrl != null && avatarUrl!.isNotEmpty) {
        await profileApi.deleteAvatar();
      }
      final url = await profileApi.uploadAvatar(filePath);
      avatarUrl = url;
      avatarPath = null;
      await reloadProfile();
    } catch (e) {
      error = 'Failed to upload avatar: $e';
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadCover(String filePath) async {
    final profileApi = GetIt.I<ProfileApi>();
    try {
      isLoading = true;
      notifyListeners();
      if (coverUrl != null && coverUrl!.isNotEmpty) {
        await profileApi.deleteCover();
      }
      final url = await profileApi.uploadCover(filePath);
      coverUrl = url;
      coverPath = null;
      await reloadProfile();
    } catch (e) {
      error = 'Failed to upload cover: $e';
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadHighlight(String filePath) async {
    final profileApi = GetIt.I<ProfileApi>();
    try {
      isLoading = true;
      notifyListeners();
      await profileApi.uploadHighlight(filePath);
      await reloadProfile();
    } catch (e) {
      error = 'Failed to upload highlight: $e';
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteHighlight(int photoId) async {
    final profileApi = GetIt.I<ProfileApi>();
    try {
      isLoading = true;
      notifyListeners();
      await profileApi.deleteHighlight(photoId);
      await reloadProfile();
    } catch (e) {
      error = 'Failed to delete highlight: $e';
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadProfile() async {
    final profileService = GetIt.I<ProfileService>();
    profile = await profileService.getProfile();
    _initFromProfile();
    notifyListeners();
  }

  // Helper method to validate image file
  Future<bool> _isValidImageFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final bytes = await file.readAsBytes();
      if (bytes.length == 0) return false;

      // Check file extension
      final extension = filePath.split('.').last.toLowerCase();
      final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!validExtensions.contains(extension)) return false;

      // Try to decode image to verify it's a valid image file
      await decodeImageFromList(bytes);
      return true;
    } catch (e) {
      print('Error validating image file: $e');
      return false;
    }
  }
}