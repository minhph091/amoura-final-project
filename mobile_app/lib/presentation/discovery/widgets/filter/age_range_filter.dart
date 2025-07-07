// lib/presentation/discovery/widgets/age_range_filter.dart

import 'package:flutter/material.dart';
import 'filter_section_header.dart';

// A filter widget for selecting an age range using a RangeSlider.
class AgeRangeFilter extends StatelessWidget {
  final RangeValues currentAgeRange;
  final ValueChanged<RangeValues> onChanged;

  const AgeRangeFilter({
    super.key,
    required this.currentAgeRange,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(
          title: 'Age Range',
          valueDisplay: '${currentAgeRange.start.round()} - ${currentAgeRange.end.round()}',
        ),
        RangeSlider(
          values: currentAgeRange,
          min: 18,
          max: 120,
          divisions: 102, // 120 - 18 = 102 divisions for integer steps
          labels: RangeLabels(
            currentAgeRange.start.round().toString(),
            currentAgeRange.end.round().toString(),
          ),
          onChanged: onChanged,
          activeColor: colorScheme.primary,
          inactiveColor: colorScheme.primary.withValues(alpha: 0.3), // Using withOpacity
        ),
      ],
    );
  }
}