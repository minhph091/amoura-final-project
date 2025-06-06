// lib/presentation/profile/setup/stepmodel/step1_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../../core/utils/validation_util.dart';
import 'base_step_viewmodel.dart';
import '../setup_profile_viewmodel.dart';

class Step1ViewModel extends BaseStepViewModel {
  String? firstName;
  String? lastName;

  Step1ViewModel(super.parent) {
    firstName = parent.firstName;
    lastName = parent.lastName;
  }

  @override
  bool get isRequired => true;

  @override
  String? validate() {
    final firstError = ValidationUtil().validateFirstName(firstName);
    if (firstError != null) return firstError;
    final lastError = ValidationUtil().validateLastName(lastName);
    if (lastError != null) return lastError;
    return null;
  }

  @override
  void saveData() {
    parent.firstName = firstName?.trim();
    parent.lastName = lastName?.trim();
    parent.profileData['firstName'] = firstName?.trim();
    parent.profileData['lastName'] = lastName?.trim();
  }
}