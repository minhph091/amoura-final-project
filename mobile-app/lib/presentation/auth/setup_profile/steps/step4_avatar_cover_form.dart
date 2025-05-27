// lib/presentation/auth/setup_profile/steps/step4_avatar_cover_form.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/setup_profile_button.dart';
import '../setup_profile_viewmodel.dart';
import '../theme/setup_profile_theme.dart';

class Step4AvatarCoverForm extends StatefulWidget {
  const Step4AvatarCoverForm({super.key});

  @override
  State<Step4AvatarCoverForm> createState() => _Step4AvatarCoverFormState();
}

class _Step4AvatarCoverFormState extends State<Step4AvatarCoverForm> {
  Future<bool> _requestPermissions(ImageSource source) async {
    // Capture the context before any async operation
    final context = this.context;

    Permission permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
    var status = await permission.status;

    if (!status.isGranted) {
      status = await permission.request();
      if (!status.isGranted) {
        // Check if the widget is still in the tree before using context
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please grant ${source == ImageSource.camera ? 'camera' : 'photo'} permission.")),
          );
        }
        return false;
      }
    }
    return true;
  }

  Future<void> _pickImage(BuildContext context, bool isAvatar) async {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, ImageSource.camera), child: const Text('Camera')),
          TextButton(onPressed: () => Navigator.pop(context, ImageSource.gallery), child: const Text('Gallery')),
        ],
      ),
    );
    if (source == null) return;
    if (!await _requestPermissions(source)) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
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
      if (compressedFile != null) {
        setState(() {
          if (isAvatar) {
            vm.avatarPath = compressedFile.path;
          } else {
            vm.coverPath = compressedFile.path;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Avatar & Cover Photo", style: SetupProfileTheme.getTitleStyle(context)),
          const SizedBox(height: 6),
          Text("Upload a vertical or square photo (max 2MB, recommended 512x512 for avatar, 1024x1024 for cover).",
              style: SetupProfileTheme.getDescriptionStyle(context)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: GestureDetector(
                        onTap: () => _pickImage(context, true),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: SetupProfileTheme.darkPink.withAlpha(20),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: SetupProfileTheme.darkPink, width: 2),
                              ),
                              child: vm.avatarPath == null
                                  ? Center(child: Icon(Icons.camera_alt, size: 48, color: SetupProfileTheme.darkPink))
                                  : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(File(vm.avatarPath!), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                              ),
                            ),
                            if (vm.avatarPath != null)
                              GestureDetector(
                                onTap: () => setState(() => vm.avatarPath = null),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(blurRadius: 2, color: Color(0xFF424242))],
                                  ),
                                  child: Icon(Icons.close, color: SetupProfileTheme.darkPink, size: 18),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("Avatar", style: SetupProfileTheme.getLabelStyle(context).copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                    Text("Your main profile photo", style: SetupProfileTheme.getDescriptionStyle(context), textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: GestureDetector(
                        onTap: () => _pickImage(context, false),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: SetupProfileTheme.darkPurple.withAlpha(25),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: SetupProfileTheme.darkPurple, width: 2),
                              ),
                              child: vm.coverPath == null
                                  ? Center(child: Icon(Icons.image, size: 48, color: SetupProfileTheme.darkPurple))
                                  : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(File(vm.coverPath!), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                              ),
                            ),
                            if (vm.coverPath != null)
                              GestureDetector(
                                onTap: () => setState(() => vm.coverPath = null),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(blurRadius: 2, color: Color(0xFF424242))],
                                  ),
                                  child: Icon(Icons.close, color: SetupProfileTheme.darkPink, size: 18),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("Cover Photo", style: SetupProfileTheme.getLabelStyle(context).copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                    Text("Large background photo", style: SetupProfileTheme.getDescriptionStyle(context), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SetupProfileButton(
            text: "Next",
            onPressed: () {
              if (vm.avatarPath == null || vm.coverPath == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload both photos.")));
                return;
              }
              vm.nextStep();
            },
            width: double.infinity,
            height: 52,
          ),
        ],
      ),
    );
  }
}