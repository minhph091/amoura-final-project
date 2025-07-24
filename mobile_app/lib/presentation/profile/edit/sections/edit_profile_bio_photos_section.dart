// lib/presentation/profile/edit/edit_profile_bio_photos_section.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../shared/widgets/image_source_bottom_sheet.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../edit_profile_viewmodel.dart';
import '../../setup/theme/setup_profile_theme.dart';
import '../../../../config/language/app_localizations.dart';

class EditProfileBioPhotosSection extends StatefulWidget {
  final EditProfileViewModel viewModel;

  const EditProfileBioPhotosSection({super.key, required this.viewModel});

  @override
  State<EditProfileBioPhotosSection> createState() =>
      _EditProfileBioPhotosSectionState();
}

class _EditProfileBioPhotosSectionState
    extends State<EditProfileBioPhotosSection> {
  final TextEditingController _bioController = TextEditingController();
  final int maxAdditionalPhotos = 4;

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.viewModel.bio ?? '';
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermissions(ImageSource source) async {
    Permission permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;
    var status = await permission.status;
    if (!status.isGranted) {
      status = await permission.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Please grant ${source == ImageSource.camera ? 'camera' : 'photo'} permission.",
              ),
            ),
          );
        }
        return false;
      }
    }
    return true;
  }

  Future<void> _addPhoto() async {
    final totalPhotos =
        widget.viewModel.existingPhotos.length +
        widget.viewModel.additionalPhotos.length;
    if (totalPhotos >= maxAdditionalPhotos) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Maximum 4 photos allowed")));
      return;
    }

    final source = await ImageSourceBottomSheet.show(context);

    if (source == null) return;
    if (!await _requestPermissions(source)) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile != null) {
      try {
        final image = await decodeImageFromList(
          await File(pickedFile.path).readAsBytes(),
        );

        // Kiểm tra kích thước và tỷ lệ ảnh
        if (image.width > image.height) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please upload a vertical or square photo"),
              ),
            );
          }
          return;
        }

        // Kiểm tra định dạng file
        final extension = pickedFile.path.split('.').last.toLowerCase();
        final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
        if (!validExtensions.contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Please upload a valid image file (JPG, PNG, GIF, WEBP)",
                ),
              ),
            );
          }
          return;
        }

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          pickedFile.path,
          "${pickedFile.path}_compressed.jpg",
          quality: 70,
          minWidth: 512,
          minHeight: 512,
        );

        if (compressedFile != null) {
          widget.viewModel.addPhoto(compressedFile.path);
          setState(() {}); // Cập nhật lại UI sau khi chọn
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error processing image: $e")));
        }
      }
    }
  }

  Future<void> _viewPhoto(String path, bool isExisting) async {
    await showDialog(
      context: context,
      builder:
          (_) => Dialog(
            insetPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: const Text('Photo'),
                  backgroundColor: ProfileTheme.darkPink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          if (isExisting) {
                            // Tìm photo ID từ path
                            final photo = widget.viewModel.profile?['photos']
                                ?.firstWhere(
                                  (p) =>
                                      p['url'] == path &&
                                      p['type'] == 'highlight',
                                  orElse: () => null,
                                );
                            if (photo != null && photo['id'] != null) {
                              widget.viewModel.removeExistingPhoto(
                                photo['id'] as int,
                              );
                            }
                          } else {
                            widget.viewModel.removePhoto(path);
                          }
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child:
                          isExisting
                              ? Image.network(
                                path,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (_, __, ___) => const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                    ),
                              )
                              : Image.file(File(path), fit: BoxFit.contain),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalExistingPhotos = widget.viewModel.existingPhotos.length;
    final totalNewPhotos = widget.viewModel.additionalPhotos.length;
    final totalPhotos = totalExistingPhotos + totalNewPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Bio', style: ProfileTheme.getLabelStyle(context)),
        const SizedBox(height: 6),
        Text(
          "Write a short introduction about yourself (max 1000 characters).",
          style: ProfileTheme.getDescriptionStyle(context),
        ),
        const SizedBox(height: 12),

        // Bio Text Field
        AppTextField(
          controller: _bioController,
          hintText: AppLocalizations.of(
            context,
          ).translate('tell_us_about_yourself'),
          prefixIcon: Icons.edit_note,
          prefixIconColor: ProfileTheme.darkPink,
          maxLines: 5,
          maxLength: 1000,
          onChanged: (value) {
            widget.viewModel.updateBio(value);
          },
          onSaved: (value) => widget.viewModel.updateBio(value ?? ''),
          style: ProfileTheme.getInputTextStyle(context),
        ),

        const SizedBox(height: 24),

        Text(
          "Your Photos ($totalPhotos/$maxAdditionalPhotos)",
          style: ProfileTheme.getLabelStyle(context),
        ),
        const SizedBox(height: 6),
        Text(
          "Upload up to 4 vertical or square photos that showcase your personality.",
          style: ProfileTheme.getDescriptionStyle(context),
        ),
        const SizedBox(height: 12),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1,
          padding: EdgeInsets.zero,
          children: [
            // Existing photos (highlights)
            ...?widget.viewModel.profile?['photos']
                ?.where((p) => p['type'] == 'highlight')
                .map(
                  (photo) => _buildPhotoItem(
                    isExisting: true,
                    path: fixLocalhostUrl(photo['url']),
                    onRemove: () {
                      if (photo['id'] != null) {
                        widget.viewModel.removeExistingPhoto(
                          photo['id'] as int,
                        );
                        setState(() {});
                      }
                    },
                    onView:
                        () => _viewPhoto(fixLocalhostUrl(photo['url']), true),
                    photoId: photo['id'] as int?,
                    type: photo['type'],
                  ),
                ),

            // Newly added photos
            ...widget.viewModel.additionalPhotos.map(
              (path) => _buildPhotoItem(
                isExisting: false,
                path: path,
                onRemove:
                    () => setState(() {
                      widget.viewModel.removePhoto(path);
                    }),
                onView: () => _viewPhoto(path, false),
              ),
            ),

            // Add photo button
            if (totalPhotos < maxAdditionalPhotos) _buildAddPhotoButton(),

            // Empty spaces to maintain grid layout
            ...List.generate(
              math.max(
                0,
                maxAdditionalPhotos -
                    totalPhotos -
                    (totalPhotos < maxAdditionalPhotos ? 1 : 0),
              ),
              (index) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoItem({
    required bool isExisting,
    required String path,
    required VoidCallback onRemove,
    required VoidCallback onView,
    int? photoId,
    String? type,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onView,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ProfileTheme.lightPurple),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  isExisting
                      ? Image.network(
                        path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: Colors.grey.withValues(alpha: 0.2),
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: ProfileTheme.darkPurple.withValues(
                                    alpha: 0.3,
                                  ),
                                  size: 40,
                                ),
                              ),
                            ),
                      )
                      : Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
            ),
          ),
        ),
        if (type == 'highlight' && photoId != null)
          Positioned(
            top: -10,
            right: -10,
            child: GestureDetector(
              onTap: () async {
                await widget.viewModel.deleteHighlight(photoId);
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: Colors.red, size: 18),
              ),
            ),
          ),
        if (!(type == 'highlight' && photoId != null))
          Positioned(
            top: -10,
            right: -10,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: Colors.red, size: 18),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _addPhoto,
      child: DottedBorder(
        options: const RoundedRectDottedBorderOptions(
          radius: Radius.circular(10),
          dashPattern: [6, 3],
          strokeWidth: 2,
          color: ProfileTheme.darkPink,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: ProfileTheme.darkPink.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  color: ProfileTheme.darkPink,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add Photo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ProfileTheme.darkPink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String fixLocalhostUrl(String? url) {
    if (url == null) return '';
    return url
        .replaceAll('http://localhost:', 'http://10.0.2.2:')
        .replaceAll('http://127.0.0.1:', 'http://10.0.2.2:');
  }
}
