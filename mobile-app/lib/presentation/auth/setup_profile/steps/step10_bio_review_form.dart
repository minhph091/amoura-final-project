// lib/presentation/auth/setup_profile/steps/step10_bio_review_form.dart
// Form widget for collecting the user's bio and additional photos.

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_text_field.dart';
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

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Bio & Photos",
              style: theme.textTheme.headlineLarge?.copyWith(
                color: const Color(0xFFD81B60),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Write a short introduction and upload additional photos.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFAB47BC),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 18),
            AppTextField(
              labelText: "Your Bio",
              labelStyle: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFFBA68C8),
                fontWeight: FontWeight.w600,
              ),
              hintText: "Tell us about yourself...",
              prefixIcon: Icons.edit_note,
              prefixIconColor: const Color(0xFFD81B60),
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
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              "Your Photos",
              style: theme.textTheme.headlineMedium?.copyWith(
                color: const Color(0xFFBA68C8),
                fontWeight: FontWeight.w600,
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
                            color: const Color(0xFFBA68C8).withAlpha(20),
                            child: const Icon(Icons.broken_image, size: 32),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => uploadedImages.remove(imgPath)),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              color: Color(0xFF424242),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFFD81B60),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                )),
                GestureDetector(
                  onTap: () {
                    // TODO: Implement image picker + permission
                  },
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
                      child: const Icon(
                        Icons.add_a_photo_rounded,
                        color: Color(0xFFD81B60),
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
                  child: SetupProfileButton(  // Already correct, no changes needed
                    text: "Finish",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Profile setup complete!")),
                        );
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