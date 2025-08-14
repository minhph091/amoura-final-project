// lib/presentation/stepmodel/step9_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../../core/services/setup_profile_service.dart';
import 'base_step_viewmodel.dart';

class Step9ViewModel extends BaseStepViewModel {
  List<String>? selectedInterestIds; // Danh sách ID sở thích được chọn
  List<String>? selectedLanguageIds; // Danh sách ID ngôn ngữ được chọn
  bool? interestedInNewLanguage; // Có muốn học ngôn ngữ mới không
  List<Map<String, String>> interestOptions = []; // Tùy chọn sở thích từ API, ép kiểu thành Map<String, String>
  List<Map<String, String>> languageOptions = []; // Tùy chọn ngôn ngữ từ API, ép kiểu thành Map<String, String>
  final SetupProfileService _setupProfileService; // Dịch vụ lấy dữ liệu từ API
  bool isLoading = false; // Trạng thái đang tải
  String? errorMessage; // Thông báo lỗi nếu có
  bool _fetched = false; // Đánh dấu đã lấy dữ liệu từ API chưa

  Step9ViewModel(super.parent, {SetupProfileService? setupProfileService})
      : _setupProfileService = setupProfileService ?? SetupProfileService() {
    // Khởi tạo giá trị từ parent (SetupProfileViewModel)
    selectedInterestIds = parent.selectedInterestIds;
    selectedLanguageIds = parent.selectedLanguageIds;
    interestedInNewLanguage = parent.interestedInNewLanguage;
  }

  // Lấy dữ liệu sở thích và ngôn ngữ từ API
  Future<void> fetchInterestsLanguagesOptions(BuildContext? context) async {
    if (_fetched && interestOptions.isNotEmpty && languageOptions.isNotEmpty) return;
    try {
      isLoading = true;
      notifyListeners();
      debugPrint('Fetching interests and languages options...');

      // [API Integration] Gọi API để lấy dữ liệu từ endpoint /profiles/options
      final options = await _setupProfileService.fetchProfileOptions();
      final interests = options['interests'] as List<dynamic>? ?? [];
      final languages = options['languages'] as List<dynamic>? ?? [];

      // [API Data Mapping] Chuyển đổi dữ liệu sở thích từ API sang định dạng Map<String, String>
      interestOptions = interests.map((option) {
        final id = option['id']?.toString() ?? '0';
        final name = option['name']?.toString() ?? 'Unknown';
        return {'value': id, 'label': name};
      }).toList().cast<Map<String, String>>();
      debugPrint('Fetched interest options: $interestOptions');

      // [API Data Mapping] Chuyển đổi dữ liệu ngôn ngữ từ API sang định dạng Map<String, String>
      languageOptions = languages.map((option) {
        final id = option['id']?.toString() ?? '0';
        final name = option['name']?.toString() ?? 'Unknown';
        return {'value': id, 'label': name};
      }).toList().cast<Map<String, String>>();
      debugPrint('Fetched language options: $languageOptions');

      _fetched = true;
    } catch (e) {
      debugPrint('Error fetching interests and languages options: $e');
      errorMessage = 'Failed to load options. Please try again.';
      interestOptions = [];
      languageOptions = [];
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage!)),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật danh sách sở thích được chọn
  void setSelectedInterestIds(List<String> interests) {
    selectedInterestIds = interests;
    parent.selectedInterestIds = interests;
    notifyListeners();
    debugPrint('Set selected interests: $interests');
  }

  // Cập nhật danh sách ngôn ngữ được chọn
  void setSelectedLanguageIds(List<String> languages) {
    selectedLanguageIds = languages;
    parent.selectedLanguageIds = languages;
    notifyListeners();
    debugPrint('Set selected languages: $languages');
  }

  // Cập nhật trạng thái muốn học ngôn ngữ mới
  void setInterestedInNewLanguage(bool value) {
    interestedInNewLanguage = value;
    parent.interestedInNewLanguage = value;
    notifyListeners();
    debugPrint('Set interested in new language: $value');
  }

  @override
  bool get isRequired => true; // Bước này bắt buộc

  @override
  String? validate() {
    // Kiểm tra xem có chọn ít nhất một sở thích không
    if (selectedInterestIds == null || selectedInterestIds!.isEmpty) {
      return 'Please select at least one interest.';
    }
    return null;
  }

  @override
  void saveData() {
    // Lưu dữ liệu mới nhất vào parent (SetupProfileViewModel)
    parent.selectedInterestIds = selectedInterestIds;
    parent.selectedLanguageIds = selectedLanguageIds;
    parent.interestedInNewLanguage = interestedInNewLanguage;

    // [API Data Preparation] Chuẩn bị dữ liệu để gửi API, chuyển đổi ID từ String sang int
    final interestIds = selectedInterestIds?.map((id) => int.tryParse(id) ?? 0).where((id) => id != 0).toList() ?? [];
    final languageIds = selectedLanguageIds?.map((id) => int.tryParse(id) ?? 0).where((id) => id != 0).toList() ?? [];
    parent.profileData['interestIds'] = interestIds.isNotEmpty ? interestIds : null;
    parent.profileData['languageIds'] = languageIds.isNotEmpty ? languageIds : null;
    parent.profileData['interestedInNewLanguage'] = interestedInNewLanguage;
    debugPrint('Saved Step 9 data: $parent.profileData');
  }
}
