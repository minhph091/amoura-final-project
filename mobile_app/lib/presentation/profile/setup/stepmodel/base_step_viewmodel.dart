// lib/presentation/profile/setup/stepmodel/base_step_viewmodel.dart
import 'package:flutter/material.dart';
import '../setup_profile_viewmodel.dart';

abstract class BaseStepViewModel extends ChangeNotifier {
  final SetupProfileViewModel parent;
  bool get isRequired;

  BaseStepViewModel(this.parent);

  String? validate();
  void saveData();
}