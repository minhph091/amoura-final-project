// lib/core/constants/profile/smoke_drink_constants.dart
// Defines smoking and drinking status options with labels, values, and icons for profile setup.

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

const List<Map<String, dynamic>> drinkOptions = [
  {
    'label': 'Never',
    'value': 'never',
    'icon': IconlyLight.closeSquare,
    'color': Colors.blue,
  },
  {
    'label': 'Occasionally',
    'value': 'occasionally',
    'icon': IconlyLight.timeCircle,
    'color': Colors.green,
  },
  {
    'label': 'Socially',
    'value': 'socially',
    'icon': IconlyLight.user2,
    'color': Colors.purple,
  },
  {
    'label': 'Regularly',
    'value': 'regularly',
    'icon': IconlyLight.activity,
    'color': Colors.orange,
  },
  {
    'label': 'Prefer not to say',
    'value': 'prefer_not_to_say',
    'icon': IconlyLight.hide,
    'color': Colors.grey,
  },
];

const List<Map<String, dynamic>> smokeOptions = [
  {
    'label': 'Never',
    'value': 'never',
    'icon': IconlyLight.closeSquare,
    'color': Colors.blue,
  },
  {
    'label': 'Occasionally',
    'value': 'occasionally',
    'icon': IconlyLight.timeCircle,
    'color': Colors.green,
  },
  {
    'label': 'Regularly',
    'value': 'regularly',
    'icon': IconlyLight.activity,
    'color': Colors.orange,
  },
  {
    'label': 'Former Smoker',
    'value': 'former_smoker',
    'icon': IconlyLight.logout,
    'color': Colors.purple,
  },
  {
    'label': 'Prefer not to say',
    'value': 'prefer_not_to_say',
    'icon': IconlyLight.hide,
    'color': Colors.grey,
  },
];