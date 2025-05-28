// lib/presentation/profile/edit/widgets/edit_profile_main_info.dart

import 'package:flutter/material.dart';
import '../../shared/profile_basic_info.dart';

class EditProfileMainInfo extends StatelessWidget {
  final String? firstName;
  final String? lastName;
  final DateTime? dob;
  final String? gender;
  final void Function(String field)? onEdit;

  const EditProfileMainInfo({
    super.key,
    this.firstName,
    this.lastName,
    this.dob,
    this.gender,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileBasicInfo(
      firstName: firstName,
      lastName: lastName,
      dob: dob,
      gender: gender,
      editable: true,
      onEdit: onEdit,
    );
  }
}