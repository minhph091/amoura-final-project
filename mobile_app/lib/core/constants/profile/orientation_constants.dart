// lib/core/constants/profile/orientation_constants.dart
// Defines sexual orientation options with labels, values, and icons for profile setup.

import 'package:flutter/material.dart';

const List<Map<String, dynamic>> orientationOptions = [
  {
    'label': 'Bisexual',
    'value': 'bisexual',
    'icon': Icons.transgender,
    'color': Colors.purple,
  },
  {
    'label': 'Homosexual',
    'value': 'homosexual',
    'icon': Icons.male,
    'color': Colors.blue,
  },
  {
    'label': 'Straight',
    'value': 'straight',
    'icon': Icons.wc,
    'color': Colors.pinkAccent,
  },
];
