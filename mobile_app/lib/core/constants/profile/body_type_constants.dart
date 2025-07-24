// lib/core/constants/profile/body_type_constants.dart
// Defines body type options with labels, values, and icons for profile setup.

import 'package:flutter/material.dart';

const List<Map<String, dynamic>> bodyTypeOptions = [
  {
    'label': 'Slim',
    'value': 'slim',
    'icon': Icons.trending_flat,
    'color': Colors.blueAccent,
  },
  {
    'label': 'Average',
    'value': 'average',
    'icon': Icons.person_outline,
    'color': Colors.green,
  },
  {
    'label': 'Athletic',
    'value': 'athletic',
    'icon': Icons.fitness_center,
    'color': Colors.orange,
  },
  {
    'label': 'Muscular',
    'value': 'muscular',
    'icon': Icons.directions_run,
    'color': Colors.redAccent,
  },
  {
    'label': 'Curvy',
    'value': 'curvy',
    'icon': Icons.woman,
    'color': Colors.pinkAccent,
  },
  {
    'label': 'Plus-size',
    'value': 'plus-size',
    'icon': Icons.person,
    'color': Colors.purple,
  },
  {
    'label': 'Prefer not to say',
    'value': 'prefer_not_to_say',
    'icon': Icons.privacy_tip,
    'color': Colors.grey,
  },
];
