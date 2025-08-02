// lib/presentation/discovery/widgets/filter_dialog.dart

import 'package:flutter/material.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/constants/profile/interest_constants.dart';
import '../../../../config/language/app_localizations.dart';

// Import the new granular filter widgets
import 'age_range_filter.dart';
import 'distance_range_filter.dart';
import 'interest_filter.dart';
import 'filter_action_buttons.dart';

// Shows a customizable filter modal bottom sheet for discovery.
Future<void> showFilterDialog(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled:
        true, // Allows the bottom sheet to take up more screen space
    backgroundColor:
        Colors.transparent, // For custom border radius on the inner container
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(30),
      ), // Top border radius
    ),
    builder: (ctx) => const FilterDialogContent(),
  );
}

// The main content of the filter dialog, managing state for all filters.
class FilterDialogContent extends StatefulWidget {
  const FilterDialogContent({super.key});

  @override
  State<FilterDialogContent> createState() => _FilterDialogContentState();
}

class _FilterDialogContentState extends State<FilterDialogContent> {
  // Current filter values
  RangeValues _ageRange = const RangeValues(18, 60);
  double _distanceValue = 50; // in km (defaulting to 50km)
  List<String> _selectedInterestIds = [];

  @override
  void initState() {
    super.initState();
    // Initialize filter values, potentially from saved preferences or an API.
    // For this frontend-only example, we'll use default values.
    _ageRange = const RangeValues(18, 60);
    _distanceValue = 50; // Single distance value
    _selectedInterestIds = []; // Starts with no interests selected
  }

  // Resets all filters to their default values.
  void _resetFilters() {
    setState(() {
      _ageRange = const RangeValues(18, 60);
      _distanceValue = 50; // Reset to default
      _selectedInterestIds = [];
    });
    // Provides user feedback
    final localizations = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.translate('filters_reset'))),
    );
  }

  // Applies the current filter settings.
  // In a real application, this would pass data to a ViewModel/Bloc/Cubit/Service.
  void _applyFilters() {
    // This is where you would send the selected filter values to your logic layer.
    debugPrint('Applying filters:');
    debugPrint(
      'Age Range: ${_ageRange.start.round()} - ${_ageRange.end.round()}',
    );
    debugPrint('Distance: ${_distanceValue.round()} km');
    debugPrint('Selected Interests: $_selectedInterestIds');

    Navigator.of(context).pop(); // Closes the dialog
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.8, // Starts at 80% of screen height
      minChildSize: 0.5, // Can be dragged down to 50%
      maxChildSize: 0.9, // Can be dragged up to 90%
      expand: false, // Does not expand to full screen immediately
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface, // Background color from theme
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Draggable handle to indicate it can be dragged
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller:
                      scrollController, // Links scroll to DraggableScrollableSheet
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate('filters'),
                        style: AppTextStyles.heading1.copyWith(
                          color: colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Age Range Filter Section
                      AgeRangeFilter(
                        currentAgeRange: _ageRange,
                        onChanged: (newRange) {
                          setState(() {
                            _ageRange = newRange;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Distance Range Filter Section
                      DistanceRangeFilter(
                        currentDistance: _distanceValue,
                        onChanged: (newRange) {
                          setState(() {
                            _distanceValue = newRange;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Interests Filter Section
                      InterestFilter(
                        selectedInterestIds: _selectedInterestIds,
                        onChanged: (newSelectedIds) {
                          setState(() {
                            _selectedInterestIds = newSelectedIds;
                          });
                        },
                        interestOptions:
                            interestOptions, // Pass interestOptions here (simulating API data)
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              // Reset and Apply buttons are placed outside the scrollable area
              FilterActionButtons(
                onReset: _resetFilters,
                onApply: _applyFilters,
              ),
              const SizedBox(height: 20), // Bottom padding
            ],
          ),
        );
      },
    );
  }
}
