// lib/presentation/auth/setup_profile/setup_profile_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'setup_profile_viewmodel.dart';
import 'steps/step1_name_form.dart';
import 'steps/step2_dob_gender_form.dart';
import '../../../core/constants/asset_path.dart';

class SetupProfileView extends StatelessWidget {
  const SetupProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SetupProfileViewModel(),
      child: Consumer<SetupProfileViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Setup Profile"),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      Hero(
                        tag: "amoura_logo",
                        child: Image.asset(
                          AssetPath.logo,
                          width: 54,
                          height: 54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Stepper(
                        currentStep: viewModel.currentStep,
                        onStepCancel: viewModel.skipStep,
                        onStepContinue: viewModel.nextStep,
                        steps: [
                          Step(
                            title: const Text("Name"),
                            content: Step1NameForm(viewModel: viewModel),
                            isActive: viewModel.currentStep == 0,
                            state: viewModel.currentStep > 0
                                ? StepState.complete
                                : StepState.editing,
                          ),
                          Step(
                            title: const Text("Birthday & Gender"),
                            content: Step2DobGenderForm(viewModel: viewModel),
                            isActive: viewModel.currentStep == 1,
                            state: viewModel.currentStep > 1
                                ? StepState.complete
                                : StepState.editing,
                          ),
                          // 8 bước tiếp sẽ bổ sung sau
                        ],
                        controlsBuilder: (context, details) {
                          return Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: details.onStepContinue,
                                  child: viewModel.currentStep == 1
                                      ? const Text("Finish")
                                      : const Text("Next"),
                                ),
                              ),
                              if (viewModel.currentStep < viewModel.totalSteps - 1)
                                TextButton(
                                  onPressed: details.onStepCancel,
                                  child: const Text("Skip"),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}