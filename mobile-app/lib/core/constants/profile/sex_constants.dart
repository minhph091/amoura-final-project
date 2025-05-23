// lib/core/constants/profile/sex_constants.dart
// Defines sex options with labels, values, and icons for profile setup.

import 'package:flutter/material.dart';

const List<Map<String, dynamic>> sexOptions = [
  {
    'label': 'Female',
    'value': 'female',
    'icon': Icons.female,
    'color': Colors.pinkAccent,
  },
  {
    'label': 'Male',
    'value': 'male',
    'icon': Icons.male,
    'color': Colors.blue,
  },
  {
    'label': 'Non-binary',
    'value': 'non-binary',
    'icon': Icons.people_outline,
    'color': Colors.purpleAccent,
  },
  {
    'label': 'Prefer not to say',
    'value': 'prefer_not_to_say',
    'icon': Icons.help_outline,
    'color': Colors.grey,
  },
];