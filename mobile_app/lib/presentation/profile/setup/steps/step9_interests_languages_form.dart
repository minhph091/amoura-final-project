import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/shake_widget.dart';
import '../widgets/setup_profile_button.dart';
import '../setup_profile_viewmodel.dart';
import '../stepmodel/step9_viewmodel.dart';
import 'widgets/_step9_widgets.dart';
import '../../../../config/language/app_localizations.dart';

class Step9InterestsLanguagesForm extends StatefulWidget {
  const Step9InterestsLanguagesForm({super.key});

  @override
  State<Step9InterestsLanguagesForm> createState() =>
      _Step9InterestsLanguagesFormState();
}

class _Step9InterestsLanguagesFormState
    extends State<Step9InterestsLanguagesForm> {
  bool _interestError = false;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context);
    final step9ViewModel = vm.stepViewModels[8] as Step9ViewModel;

    // Listen to Step9ViewModel changes for real-time UI updates
    return AnimatedBuilder(
      animation: step9ViewModel,
      builder: (context, child) {
        return _buildContent(vm, step9ViewModel);
      },
    );
  }

  Widget _buildContent(
    SetupProfileViewModel vm,
    Step9ViewModel step9ViewModel,
  ) {
    // Debug: Track UI rebuilds
    debugPrint(
      '🔄 Step9 UI rebuilding - interests: ${step9ViewModel.selectedInterestIds}, languages: ${step9ViewModel.selectedLanguageIds}',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          const InterestsLanguagesHeader(),
          const SizedBox(height: 16), // Giảm từ 20 xuống 16
          // Content Section - Fixed layout without scroll
          Expanded(
            child:
                step9ViewModel.isLoading
                    ? const InterestsLanguagesLoadingState()
                    : step9ViewModel.errorMessage != null
                    ? _buildErrorState(step9ViewModel.errorMessage!)
                    : step9ViewModel.interestOptions.isEmpty ||
                        step9ViewModel.languageOptions.isEmpty
                    ? _buildEmptyState()
                    : Column(
                      children: [
                        // Language Selector
                        LanguageSelector(step9ViewModel: step9ViewModel),
                        const SizedBox(height: 8), // Giảm từ 12 xuống 8
                        // New Language Checkbox
                        NewLanguageCheckbox(step9ViewModel: step9ViewModel),
                        const SizedBox(height: 12), // Giảm từ 16 xuống 12
                        // Interest Selector with shake animation for errors - No scroll needed
                        Expanded(
                          child: ShakeWidget(
                            shake: _interestError,
                            child: InterestSelector(
                              step9ViewModel: step9ViewModel,
                            ),
                          ),
                        ),
                      ],
                    ),
          ),

          // Next Button - Always visible at bottom
          SetupProfileButton(
            text: AppLocalizations.of(context).translate('continue_setup'),
            onPressed: () {
              final error =
                  vm.validateCurrentStep() ?? step9ViewModel.validate();
              if (error == null) {
                vm.nextStep(context: context);
              } else {
                setState(() => _interestError = true);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error)));
              }
            },
            width: double.infinity,
            height: 52,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 40),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF666666).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: const Color(0xFF666666), size: 40),
            const SizedBox(height: 12),
            Text(
              'No options available',
              style: TextStyle(
                color: const Color(0xFF666666),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
