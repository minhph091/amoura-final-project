// lib/presentation/discovery/widgets/interest_filter.dart

import 'package:flutter/material.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../../../../config/theme/text_styles.dart';
import 'filter_section_header.dart';

class InterestFilter extends StatelessWidget {
  final List<String> selectedInterestIds;
  final ValueChanged<List<String>> onChanged;
  final List<Map<String, dynamic>> interestOptions; // Received from parent

  const InterestFilter({
    super.key,
    required this.selectedInterestIds,
    required this.onChanged,
    required this.interestOptions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FilterSectionHeader(title: 'Interests'),
        const SizedBox(height: 12),
        ProfileOptionSelector(
          options: interestOptions,
          selectedValues: selectedInterestIds,
          onChanged: (value, selected) {
            List<String> newSelectedIds = List.from(selectedInterestIds);
            if (selected) {
              newSelectedIds.add(value);
            } else {
              newSelectedIds.remove(value);
            }
            onChanged(newSelectedIds);
          },
          labelText: 'Select your interests',
          labelStyle: AppTextStyles.body.copyWith(color: colorScheme.onSurface),
          isMultiSelect: true,
          scrollable: false,
          isSearchable: false,
        ),
      ],
    );
  }
}