// lib/presentation/auth/setup_profile/setup_profile_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'setup_profile_gradient_bg.dart'; // File for gradient background widget
import 'setup_profile_viewmodel.dart'; // ViewModel for managing setup profile state
import 'steps/step1_name_form.dart'; // Form for user name input
import 'steps/step2_dob_gender_form.dart'; // Form for date of birth and gender input
import 'steps/step3_orientation_form.dart'; // Form for orientation selection
import 'steps/step4_avatar_cover_form.dart'; // Form for avatar and cover photo upload
import 'steps/step5_location_form.dart'; // Form for location input
import 'steps/step6_appearance_form.dart'; // Form for appearance details
import 'steps/step7_job_education_form.dart'; // Form for job and education input
import 'steps/step8_lifestyle_form.dart'; // Form for lifestyle preferences
import 'steps/step9_interests_languages_form.dart'; // Form for interests and languages
import 'steps/step10_bio_review_form.dart'; // Form for bio and profile review

class SetupProfileView extends StatelessWidget {
  const SetupProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Create ChangeNotifierProvider to manage SetupProfileViewModel state
    return ChangeNotifierProvider(
      create: (_) => SetupProfileViewModel(),
      child: Consumer<SetupProfileViewModel>(
        builder: (context, vm, child) {
          // Wrap Scaffold with gradient background from SetupProfileGradientBg
          return SetupProfileGradientBg(
            child: Scaffold(
              backgroundColor: Colors.transparent, // Transparent background to show gradient
              body: SafeArea(
                child: Column(
                  children: [
                    // Header with title and step indicator
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0), // Padding for header
                      child: Row(
                        children: [
                          // Primary title using headlineLarge from AppTheme
                          Text(
                            'Setup Profile',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8), // Spacer between title and step
                          // Step indicator using titleMedium from AppTheme
                          Text(
                            '(${vm.currentStep + 1}/10)',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(), // Push skip button to the right
                          if (vm.showSkip)
                            TextButton(
                              onPressed: vm.onSkip, // Method to skip current step
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Custom stepper progress bar
                    _StepperProgress(totalSteps: 10, currentStep: vm.currentStep),
                    const SizedBox(height: 10), // Spacing between progress and content
                    // Expanded section for PageView with animated transitions
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300), // Animation duration for step transition
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          // Fade transition for page switch (complex syntax for custom animation)
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: PageView(
                          key: ValueKey<int>(vm.currentStep), // Unique key for animation trigger
                          controller: vm.pageController, // Controller managed by ViewModel
                          physics: const NeverScrollableScrollPhysics(), // Disable manual swipe
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
    // Get color scheme from theme for consistency
    final color = Theme.of(context).colorScheme.secondary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18), // Horizontal padding for stepper
      child: Row(
        children: List.generate(totalSteps, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: index == 0 ? 0 : 3), // Margin for segments
              height: 7, // Fixed height of progress bar
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5), // Rounded corners
                color: index <= currentStep
                    ? color // Completed steps
                    : color.withAlpha(55), // Incomplete steps
                boxShadow: [
                  if (index == currentStep)
                    BoxShadow(
                      color: color.withAlpha(110), // Shadow for current step
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