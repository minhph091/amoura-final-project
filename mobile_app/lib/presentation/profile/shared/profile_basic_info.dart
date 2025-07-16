// lib/presentation/profile/shared/profile_basic_info.dart
import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';

class ProfileBasicInfo extends StatelessWidget {
  final String? firstName;
  final String? lastName;
  final String? username;
  final DateTime? dob;
  final String? gender;
  final String? orientation;
  final bool editable;
  final void Function(String field)? onEdit;

  const ProfileBasicInfo({
    super.key,
    this.firstName,
    this.lastName,
    this.username,
    this.dob,
    this.gender,
    this.orientation,
    this.editable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16.0,
      runSpacing: 12.0,
      children: [
        _buildInfoChip(context, 'Birthday', _formatDate(dob), 'dob'),
        _buildInfoChip(context, 'Gender', gender, 'gender'),
        _buildInfoChip(context, 'Orientation', orientation, 'orientation'),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String? value, String field) {
    return InkWell(
      onTap: editable && onEdit != null ? () => onEdit!(field) : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: ProfileTheme.lightPink.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ProfileTheme.darkPink.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: ProfileTheme.darkPurple.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value ?? '-',
              style: TextStyle(
                fontSize: 14,
                color: ProfileTheme.darkPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
