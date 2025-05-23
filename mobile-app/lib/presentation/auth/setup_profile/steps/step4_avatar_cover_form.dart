// lib/presentation/auth/setup_profile/steps/step4_avatar_cover_form.dart
// Form widget for uploading the user's avatar and cover photo.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../widgets/setup_profile_button.dart';
import '../setup_profile_viewmodel.dart';

class Step4AvatarCoverForm extends StatelessWidget {
  const Step4AvatarCoverForm({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Avatar & Cover Photo",
            style: theme.textTheme.headlineLarge?.copyWith(
              color: const Color(0xFFD81B60),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "These photos will help others recognize you.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFAB47BC),
              fontStyle: FontStyle.italic,
            ),
          ),
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
                        onTap: () {
                          // TODO: Implement avatar picker
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFD81B60).withAlpha(20),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFD81B60),
                              width: 2,
                            ),
                          ),
                          child: vm.avatarPath == null
                              ? const Center(child: Icon(Icons.camera_alt, size: 48, color: Color(0xFFD81B60)))
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: UserAvatar(imageUrl: vm.avatarPath, radius: 42),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Avatar",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFBA68C8),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Your main profile photo",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFAB47BC),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                      aspectRatio: 2.5,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Implement cover picker
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF8E24AA).withAlpha(25),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF8E24AA),
                              width: 2,
                            ),
                          ),
                          child: vm.coverPath == null
                              ? const Center(child: Icon(Icons.image, size: 48, color: Color(0xFF8E24AA)))
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(vm.coverPath!, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Cover Photo",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFBA68C8),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Large background photo",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFAB47BC),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SetupProfileButton(
            text: "Next",
            onPressed: () {
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