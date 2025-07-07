// lib/presentation/profile/setup/stepmodel/step7_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../../core/services/setup_profile_service.dart';
import 'base_step_viewmodel.dart';
import '../setup_profile_viewmodel.dart';

class Step7ViewModel extends BaseStepViewModel {
  String? jobIndustryId; // API returns Long, stored as String for frontend
  String? jobIndustry;   // Name of the selected job industry
  String? educationLevelId; // API returns Long, stored as String
  String? educationLevel;   // Name of the selected education level
  bool? dropOut;
  List<Map<String, String>> jobIndustryOptions = []; // Changed from dynamic to String
  List<Map<String, String>> educationLevelOptions = []; // Changed from dynamic to String
  final SetupProfileService _setupProfileService;
  bool isLoading = false;
  String? errorMessage;
  bool _fetched = false;

  Step7ViewModel(SetupProfileViewModel parent, {SetupProfileService? setupProfileService})
      : _setupProfileService = setupProfileService ?? SetupProfileService(),
        super(parent) {
    // Initialize with parent data if available
    jobIndustryId = parent.jobIndustryId?.toString();
    jobIndustry = parent.jobIndustry;
    educationLevelId = parent.educationLevelId?.toString();
    educationLevel = parent.educationLevel;
    dropOut = parent.dropOut;
  }

  Future<void> fetchJobEducationOptions(BuildContext? context) async {
    if (_fetched && jobIndustryOptions.isNotEmpty && educationLevelOptions.isNotEmpty) return;
    try {
      isLoading = true;
      notifyListeners();
      print('Fetching job and education options...');

      final options = await _setupProfileService.fetchProfileOptions();
      final jobIndustries = options['jobIndustries'] as List<dynamic>?;
      final educationLevels = options['educationLevels'] as List<dynamic>?;

      // Map job industries to the required format
      jobIndustryOptions = jobIndustries?.map((option) {
            final id = option['id']?.toString() ?? '0';
            final name = option['name']?.toString() ?? 'Unknown';
            return {'value': id, 'label': name};
          }).toList() ??
          [];
      print('Fetched job industry options: $jobIndustryOptions');

      // Map education levels to the required format
      educationLevelOptions = educationLevels?.map((option) {
            final id = option['id']?.toString() ?? '0';
            final name = option['name']?.toString() ?? 'Unknown';
            return {'value': id, 'label': name};
          }).toList() ??
          [];
      print('Fetched education level options: $educationLevelOptions');

      // Reset selections if they are invalid
      if (jobIndustryId != null && !jobIndustryOptions.any((o) => o['value'] == jobIndustryId)) {
        jobIndustryId = null;
        jobIndustry = null;
      }
      if (educationLevelId != null && !educationLevelOptions.any((o) => o['value'] == educationLevelId)) {
        educationLevelId = null;
        educationLevel = null;
      }
      _fetched = true;
    } catch (e) {
      print('Error fetching job and education options: $e');
      errorMessage = 'Failed to load options. Please try again.';
      jobIndustryOptions = [];
      educationLevelOptions = [];
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

  void setJobIndustry(String id, String name) {
    jobIndustryId = id;
    jobIndustry = name;
    parent.jobIndustryId = int.tryParse(id);
    parent.jobIndustry = name;
    notifyListeners();
    print('Set job industry: id=$id, name=$name');
  }

  void setEducationLevel(String id, String name) {
    educationLevelId = id;
    educationLevel = name;
    parent.educationLevelId = int.tryParse(id);
    parent.educationLevel = name;
    notifyListeners();
    print('Set education level: id=$id, name=$name');
  }

  void setDropOut(bool value) {
    dropOut = value;
    parent.dropOut = value;
    notifyListeners();
    print('Set drop out: $value');
  }

  @override
  bool get isRequired => false;

  @override
  String? validate() => null; // Step 7 is optional

  @override
  void saveData() {
    parent.jobIndustryId = int.tryParse(jobIndustryId ?? '');
    parent.jobIndustry = jobIndustry;
    parent.educationLevelId = int.tryParse(educationLevelId ?? '');
    parent.educationLevel = educationLevel;
    parent.dropOut = dropOut;
    parent.profileData['jobIndustryId'] = parent.jobIndustryId;
    parent.profileData['jobIndustry'] = jobIndustry;
    parent.profileData['educationLevelId'] = parent.educationLevelId;
    parent.profileData['educationLevel'] = educationLevel;
    parent.profileData['dropOut'] = dropOut;
    print('Saved Step 7 data: $parent.profileData');
  }
}