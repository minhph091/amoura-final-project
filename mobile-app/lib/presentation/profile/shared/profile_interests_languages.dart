import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';
import 'profile_field_display.dart';
import 'theme/profile_theme.dart';

class ProfileInterestsLanguages extends StatelessWidget {
  final List<String>? interests;
  final List<String>? languages;
  final bool? interestedInNewLanguage;
  final bool editable;
  final void Function(String field)? onEdit;

  const ProfileInterestsLanguages({
    super.key,
    this.interests,
    this.languages,
    this.interestedInNewLanguage,
    this.editable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileFieldDisplay(
          label: 'Interests',
          value: interests != null && interests!.isNotEmpty ? interests!.join(', ') : null,
          icon: Icons.interests,
          iconColor: ProfileTheme.darkPink,
          required: true,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("interests") : null,
        ),
        ProfileFieldDisplay(
          label: 'Languages',
          value: languages != null && languages!.isNotEmpty ? languages!.join(', ') : null,
          icon: Icons.language,
          iconColor: ProfileTheme.darkPink,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("languages") : null,
        ),
        ProfileFieldDisplay(
          label: 'Interested In New Language',
          value: interestedInNewLanguage == null ? null : (interestedInNewLanguage! ? 'Yes' : 'No'),
          icon: Icons.translate,
          iconColor: ProfileTheme.darkPink,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("interestedInNewLanguage") : null,
          showDivider: false,
        ),
      ],
    );
  }
}