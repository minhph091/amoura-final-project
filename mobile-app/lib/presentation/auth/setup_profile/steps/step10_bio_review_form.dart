// lib/presentation/auth/setup_profile/steps/step10_bio_review_form.dart

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/photo_viewer.dart';
import '../setup_profile_viewmodel.dart';

class Step10BioReviewForm extends StatefulWidget {
  const Step10BioReviewForm({super.key});

  @override
  State<Step10BioReviewForm> createState() => _Step10BioReviewFormState();
}

class _Step10BioReviewFormState extends State<Step10BioReviewForm> {
  final _formKey = GlobalKey<FormState>();
  List<String> uploadedImages = []; // TODO: Replace with provider

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profile Setup",
              style: theme.textTheme.displayMedium?.copyWith(
                fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Step 10: Bio & Photos",
              style: theme.textTheme.displayLarge?.copyWith(
                fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                color: colorScheme.primary,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Write a short introduction about yourself and upload additional photos.",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: GoogleFonts.lato().fontFamily,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 18),
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
            const SizedBox(height: 22),
            Text(
              "Your Photos",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontFamily: GoogleFonts.lato().fontFamily,
                color: colorScheme.primary,
              ),
            ),
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
                GestureDetector(
                  onTap: () {
                    // TODO: image picker + permission
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
            const SizedBox(height: 32),
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