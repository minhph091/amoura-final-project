// lib/presentation/profile/setup/steps/step8_lifestyle_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/setup_profile_theme.dart';
import '../widgets/setup_profile_button.dart';
import '../setup_profile_viewmodel.dart';
import '../stepmodel/step8_viewmodel.dart';
import 'widgets/_step8_widgets.dart';

class Step8LifestyleForm extends StatefulWidget {
  const Step8LifestyleForm({super.key});

  @override
  State<Step8LifestyleForm> createState() => _Step8LifestyleFormState();
}

class _Step8LifestyleFormState extends State<Step8LifestyleForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context);
    final step8ViewModel = vm.stepViewModels[7] as Step8ViewModel;

    // Listen to Step8ViewModel changes for real-time UI updates
    return AnimatedBuilder(
      animation: step8ViewModel,
      builder: (context, child) {
        return _buildContent(vm, step8ViewModel);
      },
    );
  }

  Widget _buildContent(SetupProfileViewModel vm, Step8ViewModel step8ViewModel) {
    // Debug: Track UI rebuilds
    print('🔄 Step8 UI rebuilding - drink: ${step8ViewModel.drinkStatusId}, smoke: ${step8ViewModel.smokeStatusId}, pets: ${step8ViewModel.selectedPets}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section - Compact
          const LifestyleHeader(),
          const SizedBox(height: 16),
          
          // Content Section - Fixed layout without scroll
          Expanded(
            child: step8ViewModel.isLoading
                ? const LifestyleLoadingState()
                : step8ViewModel.errorMessage != null
                    ? _buildErrorState(step8ViewModel.errorMessage!)
                    : step8ViewModel.drinkStatusOptions.isEmpty || 
                      step8ViewModel.smokeStatusOptions.isEmpty || 
                      step8ViewModel.petOptions.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: [
                              // Drink Status Selector
                              DrinkStatusSelector(step8ViewModel: step8ViewModel),
                              const SizedBox(height: 10),
                              
                              // Smoke Status Selector
                              SmokeStatusSelector(step8ViewModel: step8ViewModel),
                              const SizedBox(height: 12),
                              
                              // Pet Selector - Compact design
                              Expanded(
                                child: PetSelector(step8ViewModel: step8ViewModel),
                              ),
                            ],
                          ),
          ),
          
          // Next Button - Always visible at bottom
          SetupProfileButton(
            text: 'Next',
            onPressed: () => vm.nextStep(context: context),
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
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 13,
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
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF666666).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              color: const Color(0xFF666666),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No lifestyle options available',
              style: TextStyle(
                color: const Color(0xFF666666),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}