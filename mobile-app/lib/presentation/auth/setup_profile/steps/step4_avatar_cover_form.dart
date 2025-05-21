// lib/presentation/auth/setup_profile/steps/step4_avatar_cover_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../shared/widgets/app_button.dart';
import '../setup_profile_viewmodel.dart';

class Step4AvatarCoverForm extends StatelessWidget {
  const Step4AvatarCoverForm({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // vẫn căn trái tổng thể column
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              "Your Birthday & Gender",
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontFamily: Theme.of(context).textTheme.displayMedium?.fontFamily,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 34,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),

          Align(
            alignment: Alignment.center,
            child: Text(
              "Your name will be visible to other users.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center, // label căn giữa
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: avatar picker
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withAlpha(20), // 0.08 ~ 20 alpha
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
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
                    const SizedBox(height: 6),
                    Text(
                      "Avatar",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center, // căn giữa
                    ),
                    Text(
                      "Your main profile photo",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center, // căn giữa
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center, // label căn giữa
                  children: [
                    AspectRatio(
                      aspectRatio: 2.5,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: cover picker
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withAlpha(25), // 0.10 ~ 25 alpha
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
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
                    const SizedBox(height: 6),
                    Text(
                      "Cover Photo",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center, // căn giữa
                    ),
                    Text(
                      "Large background photo",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center, // căn giữa
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          AppButton(
            text: "Next",
            width: double.infinity,
            onPressed: () {
              vm.nextStep();
            },
            height: 52,
            gradient: LinearGradient(colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ]),
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}
