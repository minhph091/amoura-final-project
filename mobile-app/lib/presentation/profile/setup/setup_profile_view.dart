import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/update_profile_usecase.dart';
import '../../../core/services/setup_profile_service.dart';
import '../../shared/widgets/app_gradient_background.dart';
import 'setup_profile_viewmodel.dart';
import 'widgets/setup_profile_header.dart';
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
  final String? sessionToken;

  const SetupProfileView({super.key, this.sessionToken});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SetupProfileViewModel(
        GetIt.I<RegisterUseCase>(),
        GetIt.I<UpdateProfileUseCase>(),
        sessionToken: sessionToken,
        setupProfileService: GetIt.I<SetupProfileService>(),
      ),
      child: Consumer<SetupProfileViewModel>(
        builder: (context, vm, child) {
          return AppGradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Column(
                  children: [
                    SetupProfileHeader(
                      currentStep: vm.currentStep + 1,
                      totalSteps: vm.totalSteps,
                      showSkip: !(vm.currentStep == 0 || vm.currentStep == 1 || vm.currentStep == 9) && vm.showSkip,
                      onBack: (vm.currentStep == 0 || vm.currentStep == 2) ? null : vm.prevStep,
                      onSkip: (vm.currentStep == 0 || vm.currentStep == 1 || vm.currentStep == 9)
                          ? null
                          : () => vm.skipStep(context: context),
                    ),
                    _StepperProgress(totalSteps: 10, currentStep: vm.currentStep + 1),
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