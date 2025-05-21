// lib/presentation/auth/setup_profile/steps/step4_avatar_cover_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/user_avatar.dart'; // Reusable avatar widget
import '../../../shared/widgets/app_button.dart'; // Reusable button widget
import '../setup_profile_viewmodel.dart'; // ViewModel for managing setup profile state

class Step4AvatarCoverForm extends StatelessWidget {
  const Step4AvatarCoverForm({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10), // Padding for form content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary title using headlineLarge from AppTheme
          Text(
            "Your Avatar & Cover Photo",
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6), // Spacing between title and description
          // Secondary description using bodyLarge from AppTheme
          Text(
            "These photos will help others recognize you.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24), // Spacing before photo upload fields
          // Row for avatar and cover photo upload
          Row(
            children: [
              // Avatar upload section
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Implement avatar picker
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: vm.avatarPath == null
                              ? const Center(child: Icon(Icons.camera_alt, size: 48))
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: UserAvatar(imageUrl: vm.avatarPath, radius: 42),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6), // Spacing between photo and label
                    // Avatar label
                    Text(
                      "Avatar",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    // Avatar description
                    Text(
                      "Your main profile photo",
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18), // Spacing between avatar and cover photo
              // Cover photo upload section
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 2.5,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Implement cover picker
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withAlpha(25),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: colorScheme.secondary,
                              width: 2,
                            ),
                          ),
                          child: vm.coverPath == null
                              ? const Center(child: Icon(Icons.image, size: 48))
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(vm.coverPath!, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6), // Spacing between photo and label
                    // Cover photo label
                    Text(
                      "Cover Photo",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    // Cover photo description
                    Text(
                      "Large background photo",
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28), // Spacing before button
          // Next button to proceed to the next step
          AppButton(
            text: "Next",
            width: double.infinity,
            onPressed: () {
              vm.nextStep();
            },
            height: 52,
            gradient: LinearGradient(colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ]),
            textStyle: theme.textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}