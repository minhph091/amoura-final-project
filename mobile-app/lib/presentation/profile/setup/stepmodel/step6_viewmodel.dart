// lib/presentation/profile/setup/stepmodel/step6_viewmodel.dart
import 'package:flutter/material.dart';
import 'base_step_viewmodel.dart';
import '../setup_profile_viewmodel.dart';
import '../../../../core/services/setup_profile_service.dart';

class Step6ViewModel extends BaseStepViewModel {
  final SetupProfileService _setupProfileService;

  List<Map<String, String>> bodyTypeOptions = [];
  String? bodyTypeId; // id dạng String
  String? bodyType;   // name
  int? height;

  bool isLoading = false;
  String? errorMessage;
  bool _fetched = false; // Đánh dấu đã fetch

  Step6ViewModel({required SetupProfileViewModel parent, SetupProfileService? setupProfileService})
      : _setupProfileService = setupProfileService ?? SetupProfileService(),
        super(parent) {
    bodyTypeId = parent.bodyTypeId?.toString();
    bodyType = parent.bodyType;
    height = parent.height;
  }

  Future<void> fetchBodyTypeOptions(BuildContext? context) async {
    if (_fetched && bodyTypeOptions.isNotEmpty) return; // Đã fetch rồi thì không fetch lại
    try {
      isLoading = true;
      notifyListeners();
      print('Fetching body type options...');

      final profileOptions = await _setupProfileService.fetchProfileOptions();
      final bodyTypes = profileOptions['bodyTypes'] as List<dynamic>?;

      if (bodyTypes == null || bodyTypes.isEmpty) {
        print('No body types data received from API');
        bodyTypeOptions = [];
      } else {
        bodyTypeOptions = bodyTypes.map((option) {
          final id = option['id']?.toString() ?? '0';
          final name = option['name']?.toString() ?? 'Unknown';
          print('Mapped body type option: id=$id, name=$name');
          return {'value': id, 'label': name}; // Đảm bảo kiểu Map<String, String>
        }).toList();
        print('Fetched body type options: $bodyTypeOptions');
      }

      if (bodyTypeId != null && !bodyTypeOptions.any((o) => o['value'] == bodyTypeId)) {
        bodyTypeId = null;
        bodyType = null;
      }
      _fetched = true;
    } catch (e) {
      print('Error fetching body type options: $e');
      errorMessage = 'Failed to load body type options. Please try again.';
      bodyTypeOptions = [];
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

  void setBodyType(String id, String name) {
    bodyTypeId = id;
    bodyType = name;
    parent.bodyTypeId = int.tryParse(id); // Lưu bodyTypeId dưới dạng int cho API
    parent.bodyType = name; // Lưu tên để tham chiếu nếu cần
    notifyListeners(); // Thông báo UI cập nhật
    print('Set body type: id=$id, name=$name');
  }

  void setHeight(int value) {
    height = value;
    parent.height = value;
    notifyListeners(); // Thông báo UI cập nhật
    print('Set height: $value cm');
  }

  @override
  bool get isRequired => false;

  @override
  String? validate() => null;

  @override
  void saveData() {
    parent.bodyTypeId = int.tryParse(bodyTypeId ?? '');
    parent.bodyType = bodyType;
    parent.height = height;
    parent.profileData['bodyTypeId'] = parent.bodyTypeId; // Lưu bodyTypeId vào profiles
    parent.profileData['bodyType'] = bodyType; // Lưu tên để debug hoặc tham chiếu
    parent.profileData['height'] = height;
    print('Saved appearance data to parent profileData: bodyTypeId=${parent.bodyTypeId}, bodyType=$bodyType, height=$height');
  }
}