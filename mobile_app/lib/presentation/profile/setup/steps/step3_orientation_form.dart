import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/language/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/setup_profile_button.dart';
import '../setup_profile_viewmodel.dart';
import '../stepmodel/step3_viewmodel.dart';
import 'widgets/_step3_widgets.dart'; // Updated import path

class Step3OrientationForm extends StatefulWidget {
  const Step3OrientationForm({super.key});

  @override
  State<Step3OrientationForm> createState() => _Step3OrientationFormState();
}

class _Step3OrientationFormState extends State<Step3OrientationForm>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context);
    final step3ViewModel = vm.stepViewModels[2] as Step3ViewModel;

    // Listen to Step3ViewModel changes for real-time UI updates
    return AnimatedBuilder(
      animation: step3ViewModel,
      builder: (context, child) {
        return _buildContent(vm, step3ViewModel);
      },
    );
  }

  Widget _buildContent(
    SetupProfileViewModel vm,
    Step3ViewModel step3ViewModel,
  ) {
    // Debug: Track UI rebuilds
    print(
      '🔄 Step3 UI rebuilding - selected orientation: ${step3ViewModel.orientationId}',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            OrientationHeader(),
            const SizedBox(height: 32),

            // Content Section
            step3ViewModel.isLoading
                ? OrientationLoadingState()
                : step3ViewModel.errorMessage != null
                ? OrientationErrorState(
                  errorMessage: step3ViewModel.errorMessage!,
                )
                : step3ViewModel.orientationOptions.isEmpty
                ? OrientationEmptyState()
                : OrientationCards(step3ViewModel: step3ViewModel),

            const SizedBox(height: 40),

            // Next Button
            SetupProfileButton(
              text: AppLocalizations.of(context).translate('next'),
              onPressed: () => vm.nextStep(context: context),
              width: double.infinity,
              height: 52,
            ).animate().slideY(
              begin: 0.3,
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 400),
            ),
          ],
        ),
      ),
    );
  }
}
