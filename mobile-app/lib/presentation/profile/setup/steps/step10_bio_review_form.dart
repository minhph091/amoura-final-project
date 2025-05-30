// lib/presentation/profile/setup/steps/step10_bio_review_form.dart

import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../shared/theme/profile_theme.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/photo_viewer.dart';
import '../setup_profile_viewmodel.dart';

class Step10BioReviewForm extends StatefulWidget {
  const Step10BioReviewForm({super.key});

  @override
  State<Step10BioReviewForm> createState() => _Step10BioReviewFormState();
}

class _Step10BioReviewFormState extends State<Step10BioReviewForm> {
  final _formKey = GlobalKey<FormState>();
  List<String> uploadedImages = [];
  final int maxAdditionalPhotos = 4;

  Future<bool> _requestPermissions(ImageSource source) async {
    Permission permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
    var status = await permission.status;
    if (!status.isGranted) {
      status = await permission.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please grant ${source == ImageSource.camera ? 'camera' : 'photo'} permission.")),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _addImage() async {
    if (uploadedImages.length >= maxAdditionalPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Max 4 additional photos allowed.")));
      return;
    }
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload a vertical or square photo.")));
        return;
      }
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        "${pickedFile.path}_compressed.jpg",
        quality: 70,
        minWidth: 512,
        minHeight: 512,
        keepExif: true,
      );
      if (compressedFile != null) setState(() => uploadedImages.add(compressedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your Bio & Photos", style: SetupProfileTheme.getTitleStyle(context)),
            const SizedBox(height: 6),
            Text("Write a short introduction and upload up to 4 vertical or square photos (max 2MB, 512x512).",
                style: SetupProfileTheme.getDescriptionStyle(context)),
            const SizedBox(height: 18),
            AppTextField(
              labelText: "Your Bio",
              labelStyle: SetupProfileTheme.getLabelStyle(context),
              hintText: "Tell us about yourself...",
              prefixIcon: Icons.edit_note,
              prefixIconColor: SetupProfileTheme.darkPink,
              maxLines: 5,
              maxLength: 1000,
              initialValue: vm.bio,
              onSaved: (v) => vm.bio = v,
              validator: (value) => value != null && value.length > 1000 ? "Bio must not exceed 1000 characters." : null,
              style: SetupProfileTheme.getInputTextStyle(context),
            ),
            const SizedBox(height: 22),
            Text("Your Photos (${uploadedImages.length}/$maxAdditionalPhotos)",
                style: SetupProfileTheme.getLabelStyle(context).copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...uploadedImages.map((imgPath) => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    GestureDetector(
                      onTap: () => showPhotoViewer(context, imgPath, tag: imgPath),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(imgPath), width: 80, height: 80, fit: BoxFit.cover),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => uploadedImages.remove(imgPath)),
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
                )),
                if (uploadedImages.length < maxAdditionalPhotos)
                  GestureDetector(
                    onTap: _addImage,
                    child: DottedBorder(
                      options: const RoundedRectDottedBorderOptions(
                        radius: Radius.circular(10),
                        dashPattern: [6, 3],
                        strokeWidth: 2,
                        color: Color(0xFFD81B60),
                      ),
                      child: Container(
                        width: 80,
                        height: 80,
                        alignment: Alignment.center,
                        child: Icon(Icons.add_a_photo_rounded, color: SetupProfileTheme.darkPink, size: 32),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: SetupProfileButton(
                    text: "Finish",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        vm.additionalPhotos = uploadedImages;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile setup complete!")));
                      }
                    },
                    width: double.infinity,
                    height: 52,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}