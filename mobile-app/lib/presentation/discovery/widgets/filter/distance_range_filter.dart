// lib/presentation/discovery/widgets/filter/distance_range_filter.dart

import 'package:flutter/material.dart';
import 'filter_section_header.dart';

// A filter widget for selecting a distance using a Slider.
class DistanceRangeFilter extends StatelessWidget {
  final double currentDistance;
  final ValueChanged<double> onChanged;

  const DistanceRangeFilter({
    super.key,
    required this.currentDistance,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(
          title: 'Distance',
          valueDisplay: '${currentDistance.round()} km',
        ),
        Slider(
          value: currentDistance,
          min: 1,
          max: 300,
          divisions: 30,
          label: "${currentDistance.round()} km",
          activeColor: colorScheme.primary,
          inactiveColor: colorScheme.primary.withValues(alpha: 0.3),
          onChanged: onChanged,
        ),
      ],
    );
  }
}