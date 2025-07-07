// lib/core/constants/profile/education_constants.dart
// Defines education level options with labels, values, and icons for profile setup.

import 'package:flutter/material.dart';

const List<Map<String, dynamic>> educationOptions = [
  {
    'label': 'High School',
    'value': 'high_school',
    'icon': Icons.book_outlined,
    'color': Colors.blue,
  },
  {
    'label': 'College Diploma / Associate Degree',
    'value': 'college_diploma',
    'icon': Icons.account_balance_outlined,
    'color': Colors.green,
  },
  {
    'label': "Bachelor's Degree",
    'value': 'bachelors_degree',
    'icon': Icons.school_outlined,
    'color': Colors.orange,
  },
  {
    'label': "Master's Degree",
    'value': 'masters_degree',
    'icon': Icons.school,
    'color': Colors.purple,
  },
  {
    'label': 'Doctorate / PhD',
    'value': 'doctorate_phd',
    'icon': Icons.star,
    'color': Colors.red,
  },
  {
    'label': 'Prefer not to say',
    'value': 'prefer_not_to_say',
    'icon': Icons.privacy_tip,
    'color': Colors.grey,
  },
];