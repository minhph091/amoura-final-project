// lib/presentation/auth/setup_profile/steps/step10_bio_review_form.dart

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_text_field.dart'; // Reusable text field widget
import '../../../shared/widgets/app_button.dart'; // Reusable button widget
import '../../../shared/widgets/photo_viewer.dart'; // Widget for viewing photos
import '../setup_profile_viewmodel.dart'; // ViewModel for managing setup profile state

class Step10BioReviewForm extends StatefulWidget {
  const Step10BioReviewForm({super.key});

  @override
  State<Step10BioReviewForm> createState() => _Step10BioReviewFormState();
}

class _Step10BioReviewFormState extends State<Step10BioReviewForm> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  List<String> uploadedImages = []; // List to store uploaded image paths (placeholder)

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10), // Padding for form content
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary title using headlineLarge from AppTheme
            Text(
              "Your Bio & Photos",
              style: theme.textTheme.headlineLarge?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6), // Spacing between title and description
            // Secondary description using bodyLarge from AppTheme
            Text(
              "Write a short introduction and upload additional photos.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 18), // Spacing before bio field
            // Bio input field
            AppTextField(
              labelText: "Your Bio",
              hintText: "Tell us about yourself...",
              prefixIcon: Icons.edit_note,
              maxLines: 5,
              maxLength: 1000,
              initialValue: vm.bio,
              onSaved: (v) => vm.bio = v,
              validator: (value) {
                if (value != null && value.length > 1000) {
                  return "Bio must not exceed 1000 characters.";
                }
                return null;
              },
            ),
            const SizedBox(height: 22), // Spacing before photo section
            // Photo upload label
            Text(
              "Your Photos",
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10), // Spacing before photo upload area
            // Photo upload area with existing photos and add button
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // Display uploaded photos
                ...uploadedImages.map((imgPath) => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    GestureDetector(
                      onTap: () => showPhotoViewer(context, imgPath, tag: imgPath),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imgPath,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: colorScheme.onSurface.withValues(alpha: 0.1),
                            child: const Icon(Icons.broken_image, size: 32),
                          ),
                        ),
                      ),
                    ),
                    // Button to remove photo
                    GestureDetector(
                      onTap: () => setState(() => uploadedImages.remove(imgPath)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              color: colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          color: colorScheme.error,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                )),
                // Add photo button
                GestureDetector(
                  onTap: () {
                    // TODO: Implement image picker + permission
                  },
                  child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      radius: const Radius.circular(10),
                      dashPattern: const [6, 3],
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.add_a_photo_rounded,
                        color: colorScheme.primary.withValues(alpha: 0.6),
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32), // Spacing before button
            // Finish button to complete setup
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: "Finish",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // TODO: Submit profile to backend
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Profile setup complete!")),
                        );
                      }
                    },
                    useThemeGradient: true,
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