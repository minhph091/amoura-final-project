// lib/presentation/profile/setup/steps/step10_bio_review_form.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/image_source_bottom_sheet.dart';
import '../theme/setup_profile_theme.dart';
import '../widgets/setup_profile_button.dart';
import 'package:dotted_border/dotted_border.dart';
import '../setup_profile_viewmodel.dart';
import '../stepmodel/step10_viewmodel.dart';

class Step10BioReviewForm extends StatefulWidget {
  const Step10BioReviewForm({super.key});

  @override
  State<Step10BioReviewForm> createState() => _Step10BioReviewFormState();
}

class _Step10BioReviewFormState extends State<Step10BioReviewForm> {
  final _formKey = GlobalKey<FormState>();
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
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final step10ViewModel = vm.stepViewModels[9] as Step10ViewModel;
    if (step10ViewModel.additionalPhotos.length >= maxAdditionalPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Max 4 additional photos allowed.")));
      return;
    }
    final source = await _showImageSourceDialog();
    if (source == null || !await _requestPermissions(source)) return;
    await _pickAndUploadImage(step10ViewModel, source);
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return ImageSourceBottomSheet.show(context);
  }

  Future<void> _pickAndUploadImage(Step10ViewModel viewModel, ImageSource source) async {
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
      if (compressedFile != null) {
        // [API Integration] Call addPhoto to upload the image to the server
        // - Endpoint: /profiles/photos/highlights
        // - Method: POST
        // - Body: Multipart file (photo)
        // - Response: {id: int, url: string, type: string, uploadedAt: string}
        await viewModel.addPhoto(compressedFile.path);
        // Force UI rebuild after successful upload
        if (mounted) setState(() {});
      }
    }
  }

  Future<void> _deletePhoto(String photoId) async {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final step10ViewModel = vm.stepViewModels[9] as Step10ViewModel;
    try {
      // [API Integration] Call deletePhoto to remove the image from the server
      // - Endpoint: /profiles/photos/highlights/{photoId}
      // - Method: DELETE
      // - Headers: Authorization Bearer <accessToken>
      // - Response: 200 OK or 404 if not found
      await step10ViewModel.deletePhoto(photoId);
      // Force UI rebuild after successful deletion
      if (mounted) setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete photo: $e')),
      );
    }
  }

  Future<void> _editPhoto(Map<String, dynamic> photo) async {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final step10ViewModel = vm.stepViewModels[9] as Step10ViewModel;
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Photo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'replace'),
            child: const Text('Replace Photo'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (action == 'replace') {
      final source = await _showImageSourceDialog();
      if (source == null || !await _requestPermissions(source)) return;
      final oldPhotoId = photo['id'];
      // [API Integration] Upload new photo first to the server
      // - This calls addPhoto which handles the POST request to /profiles/photos/highlights
      await _pickAndUploadImage(step10ViewModel, source);
      // [API Integration] Delete the old photo from the server
      // - This ensures the old photo is removed via DELETE request to /profiles/photos/highlights/{photoId}
      await step10ViewModel.deletePhoto(oldPhotoId);
      // Remove the old photo from the local list to keep UI in sync
      step10ViewModel.additionalPhotos.removeWhere((p) => p['id'] == oldPhotoId);
      // Force UI rebuild after successful replacement
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SetupProfileViewModel>(
      builder: (context, vm, child) {
        final step10ViewModel = vm.stepViewModels[9] as Step10ViewModel;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your Bio & Photos", style: ProfileTheme.getTitleStyle(context)),
                const SizedBox(height: 6),
                Text("Write a short introduction and upload up to 4 vertical or square photos (max 2MB, 512x512).",
                    style: ProfileTheme.getDescriptionStyle(context)),
                const SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: TextFormField(
                            initialValue: step10ViewModel.bio,
                            maxLines: 5,
                            maxLength: 1000,
                            onChanged: (v) => step10ViewModel.setBio(v),
                            onSaved: (v) => step10ViewModel.setBio(v ?? ''),
                            validator: (value) => value != null && value.length > 1000
                              ? "Bio must not exceed 1000 characters."
                              : null,
                            style: ProfileTheme.getInputTextStyle(context),
                            decoration: InputDecoration(
                              hintText: "Share something about yourself...",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              // Remove the prefix icon - will add it as a positioned widget
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: ProfileTheme.darkPink),
                              ),
                              contentPadding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                              // Remove the built-in counter
                              counterText: '',
                            ),
                          ),
                        ),
                        // Position the icon at the top-left corner
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Icon(
                            Icons.edit_note,
                            color: ProfileTheme.darkPink,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    // Custom character counter below the text field
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 8),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: TextEditingController(text: step10ViewModel.bio ?? ''),
                          builder: (context, value, child) {
                            final currentLength = step10ViewModel.bio?.length ?? 0;
                            return Text(
                              '$currentLength/1000 characters',
                              style: TextStyle(
                                fontSize: 12,
                                color: currentLength > 1000 ? Colors.red : Colors.grey.shade600,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text("Your Photos (${step10ViewModel.additionalPhotos.length}/$maxAdditionalPhotos)",
                    style: ProfileTheme.getLabelStyle(context).copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...step10ViewModel.additionalPhotos.map((photo) => Stack(
                      alignment: Alignment.topRight,
                      children: [
                        GestureDetector(
                          onTap: () => _editPhoto(photo),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(photo['path']), width: 80, height: 80, fit: BoxFit.cover),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _deletePhoto(photo['id']),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(blurRadius: 2, color: Color(0xFF424242))],
                            ),
                            child: Icon(Icons.close, color: ProfileTheme.darkPink, size: 18),
                          ),
                        ),
                      ],
                    )),
                    if (step10ViewModel.additionalPhotos.length < maxAdditionalPhotos)
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
                            child: Icon(Icons.add_a_photo_rounded, color: ProfileTheme.darkPink, size: 32),
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
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            try {
                              vm.nextStep(context: context); // Save and navigate
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(step10ViewModel.errorMessage ?? 'An error occurred')),
                              );
                            }
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
      },
    );
  }
}