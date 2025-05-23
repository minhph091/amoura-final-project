// lib/presentation/auth/setup_profile/setup_profile_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'setup_profile_viewmodel.dart';

class SetupProfileView extends StatelessWidget {
  const SetupProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final sessionToken = args?['sessionToken'] as String?;

    return ChangeNotifierProvider(
      create: (_) => SetupProfileViewModel(sessionToken: sessionToken),
      child: Consumer<SetupProfileViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Setup Profile"),
              leading: vm.currentStep > 1
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: vm.prevStep,
                    )
                  : null,
            ),
            body: Container(
              height: double.infinity, // Đảm bảo chiều cao đầy đủ
              child: IndexedStack(
                index: vm.currentStep,
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
          );
        },
      ),
    );
  }
}