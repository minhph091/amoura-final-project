// lib/presentation/auth/setup_profile/setup_profile_view.dart
// Main view for the setup profile flow, managing navigation between steps.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
                          // Back button (visible after the first step)
                          if (vm.currentStep > 0)
                            TextButton(
                              onPressed: () {
                                vm.prevStep();
                                // Placeholder for API call (to be implemented by others)
                                // Example: await apiService.saveProgress();
                              },
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  color: Color(0xFFD81B60),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ).animate(
                              onPlay: (controller) => controller.repeat(reverse: true),
                            ).scale(
                              duration: const Duration(milliseconds: 800),
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.05, 1.05),
                              curve: Curves.easeInOut,
                            ),
                          // Setup Profile title and step indicator
                          Text(
                            'Setup Profile',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFEC407A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${vm.currentStep + 1}/10)',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF8E24AA),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // Skip button (visible for non-required steps)
                          if (vm.showSkip)
                            TextButton(
                              onPressed: () {
                                vm.onSkip();
                                // Placeholder for API call (to be implemented by others)
                                // Example: await apiService.skipStep();
                              },
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  color: Color(0xFFD81B60),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ).animate(
                              onPlay: (controller) => controller.repeat(reverse: true),
                            ).scale(
                              duration: const Duration(milliseconds: 800),
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.05, 1.05),
                              curve: Curves.easeInOut,
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
                      ).animate().fadeIn(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ).slideX(
                        begin: 0.1,
                        end: 0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
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

// Widget to display the progress stepper for the setup profile flow.
class _StepperProgress extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const _StepperProgress({
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF8E24AA);
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
                color: index <= currentStep ? color : color.withAlpha(55),
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