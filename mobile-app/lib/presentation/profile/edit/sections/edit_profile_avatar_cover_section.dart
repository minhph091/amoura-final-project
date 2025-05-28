import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../setup/theme/setup_profile_theme.dart';
import '../edit_profile_viewmodel.dart';

class EditProfileAvatarCoverSection extends StatefulWidget {
  final EditProfileViewModel viewModel;

  const EditProfileAvatarCoverSection({
    super.key,
    required this.viewModel,
  });

  @override
  State<EditProfileAvatarCoverSection> createState() => _EditProfileAvatarCoverSectionState();
}

class _EditProfileAvatarCoverSectionState extends State<EditProfileAvatarCoverSection> {
  Future<bool> _requestPermissions(ImageSource source) async {
    Permission permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
    var status = await permission.status;

    if (!status.isGranted) {
      status = await permission.request();
      if (!status.isGranted) {
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

  Future<void> _pickImage(bool isAvatar) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source', style: TextStyle(color: ProfileTheme.darkPurple)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: Text('Camera', style: TextStyle(color: ProfileTheme.darkPink)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Text('Gallery', style: TextStyle(color: ProfileTheme.darkPink)),
          ),
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please upload a vertical or square photo.")),
          );
        }
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
        if (isAvatar) {
          widget.viewModel.updateAvatar(compressedFile.path);
        } else {
          widget.viewModel.updateCover(compressedFile.path);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cover Photo
        Stack(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                color: ProfileTheme.darkPurple.withOpacity(0.1),
              ),
              child: widget.viewModel.coverPath != null
                  ? ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Image.file(
                  File(widget.viewModel.coverPath!),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              )
                  : widget.viewModel.coverUrl != null
                  ? ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Image.network(
                  widget.viewModel.coverUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(Icons.image, size: 50, color: ProfileTheme.darkPurple),
                  ),
                ),
              )
                  : Center(
                child: Icon(Icons.image, size: 50, color: ProfileTheme.darkPurple),
              ),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                child: IconButton(
                  icon: Icon(Icons.edit, color: ProfileTheme.darkPink),
                  onPressed: () => _pickImage(false),
                  tooltip: 'Change Cover Photo',
                ),
              ),
            ),
          ],
        ),

        // Avatar Photo
        Transform.translate(
          offset: const Offset(0, -50),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: ProfileTheme.lightPink.withOpacity(0.2),
                  backgroundImage: _getAvatarProvider(),
                  child: _showDefaultAvatar()
                      ? Icon(Icons.person, size: 60, color: ProfileTheme.darkPink)
                      : null,
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.edit, color: ProfileTheme.darkPink, size: 20),
                  onPressed: () => _pickImage(true),
                  tooltip: 'Change Avatar',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider? _getAvatarProvider() {
    if (widget.viewModel.avatarPath != null) {
      return FileImage(File(widget.viewModel.avatarPath!));
    } else if (widget.viewModel.avatarUrl != null && widget.viewModel.avatarUrl!.isNotEmpty) {
      return NetworkImage(widget.viewModel.avatarUrl!);
    }
    return null;
  }

  bool _showDefaultAvatar() {
    return widget.viewModel.avatarPath == null &&
        (widget.viewModel.avatarUrl == null || widget.viewModel.avatarUrl!.isEmpty);
  }
}