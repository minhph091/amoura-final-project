// lib/presentation/auth/setup_profile/setup_profile_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'setup_profile_gradient_bg.dart';
import 'setup_profile_viewmodel.dart';
import 'steps/step1_name_form.dart';
import 'steps/step2_dob_gender_form.dart';
import 'steps/step3_orientation_form.dart';
import 'steps/step4_avatar_cover_form.dart';
import 'steps/step5_location_form.dart';
import 'steps/step6_appearance_form.dart';
import 'steps/step7_job_education_form.dart';
import 'steps/step8_lifestyle_form.dart';
import 'steps/step9_interests_languages_form.dart';
import 'steps/step10_bio_review_form.dart';

class SetupProfileView extends StatelessWidget {
  const SetupProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SetupProfileViewModel(),
      child: Consumer<SetupProfileViewModel>(
        builder: (context, vm, child) {
          return SetupProfileGradientBg(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                      child: Row(
                        children: [
                          Text(
                            'Setup Profile',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Dancing Script',
                              fontSize: 20,
                              color: Colors.purple[500],
                              shadows: [Shadow(blurRadius: 4, color: Colors.pinkAccent.shade100)],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${vm.currentStep + 1}/10)',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.pinkAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (vm.showSkip)
                            TextButton(
                              onPressed: vm.onSkip,
                              child: const Text('Skip',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _StepperProgress(totalSteps: 10, currentStep: vm.currentStep),
                    const SizedBox(height: 10),
                    Expanded(
                      child: PageView(
                        controller: vm.pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          Step1NameForm(),
                          Step2DobGenderForm(),
                          Step3OrientationForm(),
                          Step4AvatarCoverForm(),
                          Step5LocationForm(),
                          Step6AppearanceForm(),
                          Step7JobEducationForm(),
                          Step8LifestyleForm(),
                          Step9InterestsLanguagesForm(),
                          Step10BioReviewForm(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StepperProgress extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  const _StepperProgress({
    required this.totalSteps,
    required this.currentStep,
  });
  @override
  Widget build(BuildContext context) {
    final color = Colors.pinkAccent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: List.generate(totalSteps, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: index == 0 ? 0 : 3),
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: index <= currentStep
                    ? color
                    : color.withAlpha(55),
                boxShadow: [
                  if (index == currentStep)
                    BoxShadow(
                      color: color.withAlpha(110),
                      blurRadius: 9,
                      spreadRadius: 2,
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}