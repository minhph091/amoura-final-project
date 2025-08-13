// lib/core/constants/profile/pet_constants.dart
// Defines pet options with labels, values, and icons for profile setup using FontAwesome icons.

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const List<Map<String, dynamic>> petOptions = [
  {
    'label': 'Bird',
    'value': 'bird',
    'icon': FontAwesomeIcons.dove,
    'color': Colors.yellow,
  },
  {
    'label': 'Cat',
    'value': 'cat',
    'icon': FontAwesomeIcons.cat,
    'color': Colors.orange,
  },
  {
    'label': 'Dog',
    'value': 'dog',
    'icon': FontAwesomeIcons.dog,
    'color': Colors.brown,
  },
  {
    'label': 'Fish',
    'value': 'fish',
    'icon': FontAwesomeIcons.fish,
    'color': Colors.blue,
  },
  {
    'label': 'Hamster',
    'value': 'hamster',
    'icon': FontAwesomeIcons.paw,
    'color': Colors.pink,
  },
  {
    'label': 'Horse',
    'value': 'horse',
    'icon': FontAwesomeIcons.horse,
    'color': Colors.purple,
  },
  {
    'label': 'Rabbit',
    'value': 'rabbit',
    'icon': FontAwesomeIcons.bugs,
    'color': Colors.green,
  },
  {
    'label': 'Reptile',
    'value': 'reptile',
    'icon': FontAwesomeIcons.dragon,
    'color': Colors.teal,
  },
  {
    'label': 'Other',
    'value': 'other',
    'icon': FontAwesomeIcons.question,
    'color': Colors.grey,
  },
];
