// lib/presentation/profile/setup/steps/step7_job_education_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/setup_profile_theme.dart';
import '../widgets/setup_profile_button.dart';
import '../setup_profile_viewmodel.dart';
import '../stepmodel/step7_viewmodel.dart';
import 'widgets/_step7_widgets.dart';

class Step7JobEducationForm extends StatefulWidget {
  const Step7JobEducationForm({super.key});

  @override
  State<Step7JobEducationForm> createState() => _Step7JobEducationFormState();
}

class _Step7JobEducationFormState extends State<Step7JobEducationForm> {
  String? _activeDropdown; // Track which dropdown is currently open

  void _setActiveDropdown(String? dropdown) {
    setState(() {
      _activeDropdown = dropdown;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context);
    final step7ViewModel = vm.stepViewModels[6] as Step7ViewModel;

    // Listen to Step7ViewModel changes for real-time UI updates
    return AnimatedBuilder(
      animation: step7ViewModel,
      builder: (context, child) {
        return _buildContent(vm, step7ViewModel);
      },
    );
  }

  Widget _buildContent(SetupProfileViewModel vm, Step7ViewModel step7ViewModel) {
    // Debug: Track UI rebuilds
    print('🔄 Step7 UI rebuilding - jobIndustry: ${step7ViewModel.jobIndustryId}, education: ${step7ViewModel.educationLevelId}, dropout: ${step7ViewModel.dropOut}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          const JobEducationHeader(),
          const SizedBox(height: 24),
          
          // Content Section - Fixed layout without scrolling
          Expanded(
            child: step7ViewModel.isLoading
                ? const JobEducationLoadingState()
              : step7ViewModel.errorMessage != null
                    ? _buildErrorState(step7ViewModel.errorMessage!)
                    : step7ViewModel.jobIndustryOptions.isEmpty || step7ViewModel.educationLevelOptions.isEmpty
                        ? _buildEmptyState()
                  : Column(
                      children: [
                              // Job Industry Selector - always visible
                              JobIndustrySelector(
                                step7ViewModel: step7ViewModel,
                                onToggleExpanded: (isExpanded) {
                                  _setActiveDropdown(isExpanded ? 'job' : null);
                                },
                              ),
                              
                              // Show other elements only when job dropdown is not active
                              if (_activeDropdown != 'job') ...[
                                const SizedBox(height: 20),
                                
                                // Education Level Selector
                                EducationLevelSelector(
                                  step7ViewModel: step7ViewModel,
                                  onToggleExpanded: (isExpanded) {
                                    _setActiveDropdown(isExpanded ? 'education' : null);
                                  },
                                ),
                                
                                // Show dropout switch only when education dropdown is not active
                                if (_activeDropdown != 'education') ...[
                                  const SizedBox(height: 20),
                                  
                                  // Dropout Switch
                                  DropoutSwitch(step7ViewModel: step7ViewModel),
                                ],
                              ],
                              
                              // Spacer to push button to bottom
                              const Spacer(),
                              
                              // Next Button - always visible
                              SetupProfileButton(
                  text: 'Next',
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
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 40,
            ),
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
          color: const Color(0xFF666666).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              color: const Color(0xFF666666),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'No career options available',
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