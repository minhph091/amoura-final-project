// lib/presentation/profile/setup/stepmodel/step3_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../../core/services/setup_profile_service.dart';
import 'base_step_viewmodel.dart';
import '../setup_profile_viewmodel.dart';

class Step3ViewModel extends BaseStepViewModel {
  String? orientationId; // id dạng String
  String? orientation;   // name
  List<Map<String, String>> orientationOptions = []; // Sửa kiểu từ dynamic thành String
  final SetupProfileService _setupProfileService;
  bool isLoading = false;
  String? errorMessage;
  bool _fetched = false;

  Step3ViewModel(super.parent, {SetupProfileService? setupProfileService})
      : _setupProfileService = setupProfileService ?? SetupProfileService() {
    orientationId = parent.orientationId?.toString();
    orientation = parent.orientation;
  }

  Future<void> fetchOrientationOptions(BuildContext? context) async {
    if (_fetched && orientationOptions.isNotEmpty) return;
    try {
      isLoading = true;
      notifyListeners();
      print('Fetching orientation options...');

      final options = await _setupProfileService.fetchProfileOptions();
      final orientations = options['orientations'] as List<dynamic>?;

      if (orientations == null || orientations.isEmpty) {
        print('No orientations data received from API');
        orientationOptions = [];
      } else {
        orientationOptions = orientations.map((option) {
          final id = option['id']?.toString() ?? '0';
          final name = option['name']?.toString() ?? 'Unknown';
          print('Mapped orientation option: id=$id, name=$name');
          return {'value': id, 'label': name}; // Đảm bảo kiểu Map<String, String>
        }).toList();
        print('Fetched orientation options: $orientationOptions');
      }

      if (orientationId != null && !orientationOptions.any((o) => o['value'] == orientationId)) {
        orientationId = null;
        orientation = null;
      }
      _fetched = true;
    } catch (e) {
      print('Error fetching orientation options: $e');
      errorMessage = 'Failed to load orientation options. Please try again.';
      orientationOptions = [];
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

  void setOrientation(String id, String name) {
    orientationId = id;
    orientation = name;
    parent.orientationId = int.tryParse(id);
    parent.orientation = name;
    notifyListeners();
    print('Set orientation: id=$id, name=$name');
  }

  @override
  bool get isRequired => false;

  @override
  String? validate() => null;

  @override
  void saveData() {
    parent.orientationId = int.tryParse(orientationId ?? '');
    parent.orientation = orientation;
    parent.profileData['orientationId'] = parent.orientationId;
    parent.profileData['orientation'] = orientation;
    print('Saved orientation data to parent profileData: orientationId=${parent.orientationId}, orientation=$orientation');
  }
}