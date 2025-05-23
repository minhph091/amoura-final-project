// lib/core/constants/setup_profile_colors.dart
// Defines gradient colors for setup profile steps.

import 'package:flutter/material.dart';

const List<List<Color>> setupProfileColor = [
  [Color(0xffF7B0EC), Color(0xffC2E9FB), Color(0xffF7F0FA)], // Step 1: Pink to light blue
  [Color(0xffF7B0EC), Color(0xffA8E1F9), Color(0xffE0D4FA)], // Step 2: Slightly shift to blue
  [Color(0xffE8A4E6), Color(0xff90D9F7), Color(0xffD9C8F5)], // Step 3
  [Color(0xffD998E0), Color(0xff78D0F5), Color(0xffD2BCF0)], // Step 4
  [Color(0xffCA8CDA), Color(0xff60C8F3), Color(0xffCCB0EB)], // Step 5
  [Color(0xffBB80D4), Color(0xff48BFF1), Color(0xffC5A4E6)], // Step 6
  [Color(0xffAC74CE), Color(0xff30B7EF), Color(0xffBE98E1)], // Step 7
  [Color(0xff9D68C8), Color(0xff18AEED), Color(0xffB78CDC)], // Step 8
  [Color(0xff8E5CC2), Color(0xff00A6EB), Color(0xffB080D7)], // Step 9
  [Color(0xff7F50BC), Color(0xff009EE3), Color(0xffAA74D2)], // Step 10: Purple to deep blue
];

List<Color> getGradientForStep(int step, int totalSteps) {
  final index = (step / (totalSteps - 1) * (setupProfileColor.length - 1)).round();
  return setupProfileColor[index];
}