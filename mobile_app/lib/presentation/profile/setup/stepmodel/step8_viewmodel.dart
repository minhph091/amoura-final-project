// lib/presentation/profile/setup/stepmodel/step8_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../../core/services/setup_profile_service.dart';
import 'base_step_viewmodel.dart';
import '../setup_profile_viewmodel.dart';

class Step8ViewModel extends BaseStepViewModel {
  String? drinkStatusId; // API returns Long, stored as String for frontend
  String? drinkStatus;   // Name of the selected drink status
  String? smokeStatusId; // API returns Long, stored as String
  String? smokeStatus;   // Name of the selected smoke status
  List<String>? selectedPets; // List of pet IDs
  List<Map<String, String>> drinkStatusOptions = []; // Changed to List<Map<String, String>>
  List<Map<String, String>> smokeStatusOptions = []; // Changed to List<Map<String, String>>
  List<Map<String, String>> petOptions = []; // Changed to List<Map<String, String>>
  final SetupProfileService _setupProfileService;
  bool isLoading = false;
  String? errorMessage;
  bool _fetched = false;

  Step8ViewModel(SetupProfileViewModel parent, {SetupProfileService? setupProfileService})
      : _setupProfileService = setupProfileService ?? SetupProfileService(),
        super(parent) {
    // Initialize with parent data if available
    drinkStatusId = parent.drinkStatusId?.toString();
    drinkStatus = parent.drinkStatus;
    smokeStatusId = parent.smokeStatusId?.toString();
    smokeStatus = parent.smokeStatus;
    selectedPets = parent.selectedPets;
  }

  Future<void> fetchLifestyleOptions(BuildContext? context) async {
    if (_fetched && drinkStatusOptions.isNotEmpty && smokeStatusOptions.isNotEmpty && petOptions.isNotEmpty) return;
    try {
      isLoading = true;
      notifyListeners();
      print('Fetching lifestyle options...');

      final options = await _setupProfileService.fetchProfileOptions();
      final drinkStatuses = options['drinkStatuses'] as List<dynamic>?;
      final smokeStatuses = options['smokeStatuses'] as List<dynamic>?;
      final pets = options['pets'] as List<dynamic>?;

      // Map drink statuses to the required format
      drinkStatusOptions = drinkStatuses?.map((option) {
            final id = option['id']?.toString() ?? '0';
            final name = option['name']?.toString() ?? 'Unknown';
            return {'value': id, 'label': name};
          }).toList() ??
          [];
      print('Fetched drink status options: $drinkStatusOptions');

      // Map smoke statuses to the required format
      smokeStatusOptions = smokeStatuses?.map((option) {
            final id = option['id']?.toString() ?? '0';
            final name = option['name']?.toString() ?? 'Unknown';
            return {'value': id, 'label': name};
          }).toList() ??
          [];
      print('Fetched smoke status options: $smokeStatusOptions');

      // Map pets to the required format
      petOptions = pets?.map((option) {
            final id = option['id']?.toString() ?? '0';
            final name = option['name']?.toString() ?? 'Unknown';
            return {'value': id, 'label': name};
          }).toList() ??
          [];
      print('Fetched pet options: $petOptions');

      // Reset selections if they are invalid
      if (drinkStatusId != null && !drinkStatusOptions.any((o) => o['value'] == drinkStatusId)) {
        drinkStatusId = null;
        drinkStatus = null;
      }
      if (smokeStatusId != null && !smokeStatusOptions.any((o) => o['value'] == smokeStatusId)) {
        smokeStatusId = null;
        smokeStatus = null;
      }
      if (selectedPets != null && selectedPets!.isNotEmpty) {
        selectedPets = selectedPets!.where((pet) => petOptions.any((o) => o['value'] == pet)).toList();
      }
      _fetched = true;
    } catch (e) {
      print('Error fetching lifestyle options: $e');
      errorMessage = 'Failed to load options. Please try again.';
      drinkStatusOptions = [];
      smokeStatusOptions = [];
      petOptions = [];
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

  void setDrinkStatus(String id, String name) {
    drinkStatusId = id;
    drinkStatus = name;
    parent.drinkStatusId = int.tryParse(id);
    parent.drinkStatus = name;
    notifyListeners();
    print('Set drink status: id=$id, name=$name');
  }

  void setSmokeStatus(String id, String name) {
    smokeStatusId = id;
    smokeStatus = name;
    parent.smokeStatusId = int.tryParse(id);
    parent.smokeStatus = name;
    notifyListeners();
    print('Set smoke status: id=$id, name=$name');
  }

  void setSelectedPets(List<String> pets) {
    selectedPets = pets;
    parent.selectedPets = pets;
    notifyListeners();
    print('Set selected pets: $pets');
  }

  @override
  bool get isRequired => false;

  @override
  String? validate() => null; // Step 8 is optional

  @override
  void saveData() {
    parent.drinkStatusId = int.tryParse(drinkStatusId ?? '');
    parent.drinkStatus = drinkStatus;
    parent.smokeStatusId = int.tryParse(smokeStatusId ?? '');
    parent.smokeStatus = smokeStatus;
    parent.selectedPets = selectedPets;
    parent.profileData['drinkStatusId'] = parent.drinkStatusId;
    parent.profileData['drinkStatus'] = drinkStatus;
    parent.profileData['smokeStatusId'] = parent.smokeStatusId;
    parent.profileData['smokeStatus'] = smokeStatus;
    parent.profileData['petIds'] = selectedPets; // Update to match backend field
    print('Saved Step 8 data: $parent.profileData');
  }
}