// lib/presentation/profile/setup/stepmodel/step4_viewmodel.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/setup_profile_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/auth_service.dart';
import 'base_step_viewmodel.dart';
import '../setup_profile_viewmodel.dart';
import 'package:get_it/get_it.dart';

class Step4ViewModel extends BaseStepViewModel {
  final SetupProfileService _setupProfileService;
  String? avatarPath;
  String? coverPath;
  bool isUploading = false;

  Step4ViewModel(super.parent, {SetupProfileService? setupProfileService})
      : _setupProfileService = setupProfileService ?? SetupProfileService() {
    // Khởi tạo giá trị ban đầu từ parent
    avatarPath = parent.avatarPath;
    coverPath = parent.coverPath;
  }

  @override
  bool get isRequired => true;

  Future<bool> _requestPermissions(ImageSource source) async {
    Permission permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
    var status = await permission.status;

    if (!status.isGranted) {
      status = await permission.request();
      if (!status.isGranted) {
        return false;
      }
    }
    return true;
  }

  Future<void> pickImage(BuildContext context, bool isAvatar) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
    if (source == null) return;
    if (!await _requestPermissions(source)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please grant ${source == ImageSource.camera ? 'camera' : 'photo'} permission.",
          ),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (pickedFile == null) return;

    final image = await decodeImageFromList(await File(pickedFile.path).readAsBytes());
    if (image.width > image.height) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a vertical or square photo.")),
      );
      return;
    }

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      pickedFile.path,
      "${pickedFile.path}_compressed.jpg",
      quality: 70,
      minWidth: isAvatar ? 512 : 1024,
      minHeight: isAvatar ? 512 : 1024,
      keepExif: true,
    );
    if (compressedFile == null) return;

    await uploadImage(context, compressedFile.path, isAvatar);
  }

  Future<void> editImage(BuildContext context, String url, bool isAvatar) async {
    try {
      // Lấy access token để tải ảnh
      final authService = GetIt.I<AuthService>();
      final accessToken = await authService.getAccessToken();
      final adjustedUrl = url.replaceFirst('localhost', '10.0.2.2'); // Điều chỉnh URL cho emulator
      final response = await http.get(
        Uri.parse(adjustedUrl),
        headers: {
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }

      // Lưu ảnh vào file tạm
      final tempDir = await Directory.systemTemp.createTemp();
      final tempFile = File('${tempDir.path}/temp_image.jpg');
      await tempFile.writeAsBytes(response.bodyBytes);

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: tempFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Photo',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Edit Photo',
            aspectRatioLockEnabled: true,
          ),
        ],
      );
      if (croppedFile == null) return;

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path,
        "${croppedFile.path}_compressed.jpg",
        quality: 70,
        minWidth: isAvatar ? 512 : 1024,
        minHeight: isAvatar ? 512 : 1024,
        keepExif: true,
      );
      if (compressedFile == null) return;

      await uploadImage(context, compressedFile.path, isAvatar);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load image for editing: $e')),
      );
    }
  }

  Future<void> uploadImage(BuildContext context, String path, bool isAvatar) async {
    isUploading = true;
    notifyListeners();

    try {
      final file = File(path);
      final endpoint = isAvatar ? ApiEndpoints.uploadAvatar : ApiEndpoints.uploadCover;
      final response = await _setupProfileService.uploadPhoto(file, endpoint);
      final url = response['url'] as String;
      final adjustedUrl = url.replaceFirst('localhost', '10.0.2.2'); // Điều chỉnh URL cho emulator

      if (isAvatar) {
        avatarPath = adjustedUrl;
        parent.avatarPath = adjustedUrl;
        parent.profileData['avatarPath'] = adjustedUrl;
      } else {
        coverPath = adjustedUrl;
        parent.coverPath = adjustedUrl;
        parent.profileData['coverPath'] = adjustedUrl;
      }
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  @override
  String? validate() {
    if (avatarPath == null || coverPath == null) {
      return 'Please upload both avatar and cover photos.';
    }
    return null;
  }

  @override
  void saveData() {
    parent.avatarPath = avatarPath;
    parent.coverPath = coverPath;
    parent.profileData['avatarPath'] = avatarPath;
    parent.profileData['coverPath'] = coverPath;
  }
}