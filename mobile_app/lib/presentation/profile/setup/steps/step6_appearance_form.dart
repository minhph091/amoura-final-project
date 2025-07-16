// lib/presentation/profile/setup/steps/step6_appearance_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/setup_profile_button.dart';
import '../setup_profile_viewmodel.dart';
import '../stepmodel/step6_viewmodel.dart';
import 'widgets/_step6_widgets.dart';
import '../../../../config/language/app_localizations.dart';

class Step6AppearanceForm extends StatefulWidget {
  const Step6AppearanceForm({super.key});

  @override
  State<Step6AppearanceForm> createState() => _Step6AppearanceFormState();
}

class _Step6AppearanceFormState extends State<Step6AppearanceForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context);
    final step6ViewModel = vm.stepViewModels[5] as Step6ViewModel;

    // Listen to Step6ViewModel changes for real-time UI updates
    return AnimatedBuilder(
      animation: step6ViewModel,
      builder: (context, child) {
        return _buildContent(vm, step6ViewModel);
      },
    );
  }

  Widget _buildContent(
    SetupProfileViewModel vm,
    Step6ViewModel step6ViewModel,
  ) {
    // Debug: Track UI rebuilds
    debugPrint(
      '🔄 Step6 UI rebuilding - selected bodyType: ${step6ViewModel.bodyTypeId}, height: ${step6ViewModel.height}',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          const AppearanceHeader(),
          const SizedBox(height: 24),

          // Content Section - Fixed layout without scrolling
          Expanded(
            child:
                step6ViewModel.isLoading
                    ? const AppearanceLoadingState()
                    : step6ViewModel.errorMessage != null
                    ? _buildErrorState(step6ViewModel.errorMessage!)
                    : step6ViewModel.bodyTypeOptions.isEmpty
                    ? _buildEmptyState()
                    : Column(
                      children: [
                        // Body Type Selector
                        BodyTypeSelector(step6ViewModel: step6ViewModel),
                        const SizedBox(height: 24),

                        // Height Selector
                        HeightSelector(step6ViewModel: step6ViewModel),

                        // Spacer to push button to bottom
                        const Spacer(),

                        // Next Button
                        SetupProfileButton(
                          text: AppLocalizations.of(
                            context,
                          ).translate('continue_setup'),
                          onPressed: () => vm.nextStep(context: context),
                          width: double.infinity,
                          height: 52,
                        ),
                      ],
                    ),
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
          children: [
            Icon(Icons.search_off, color: const Color(0xFF666666), size: 40),
            const SizedBox(height: 12),
            Text(
              'No appearance options available',
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
