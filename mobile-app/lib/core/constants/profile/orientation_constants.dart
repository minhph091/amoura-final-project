// lib/core/constants/profile/orientation_constants.dart
// Defines sexual orientation options with labels, values, and icons for profile setup.

import 'package:flutter/material.dart';

const List<Map<String, dynamic>> orientationOptions = [
  {
    'label': 'Attracted to Men',
    'value': 'men',
    'icon': Icons.male,
    'color': Colors.blue,
  },
  {
    'label': 'Attracted to Women',
    'value': 'women',
    'icon': Icons.female,
    'color': Colors.pinkAccent,
  },
  {
    'label': 'Attracted to Both',
    'value': 'both',
    'icon': Icons.favorite,
    'color': Colors.purple,
  },
];