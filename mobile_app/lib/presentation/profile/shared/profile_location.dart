import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';
import 'profile_field_display.dart';

class ProfileLocation extends StatelessWidget {
  final String? city;
  final String? state;
  final String? country;
  final int? locationPreference;
  final bool editable;
  final void Function(String field)? onEdit;

  const ProfileLocation({
    super.key,
    this.city,
    this.state,
    this.country,
    this.locationPreference,
    this.editable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileFieldDisplay(
          label: 'City',
          value: city,
          icon: Icons.location_city,
          iconColor: ProfileTheme.darkPink,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("city") : null,
        ),
        ProfileFieldDisplay(
          label: 'State',
          value: state,
          icon: Icons.map,
          iconColor: ProfileTheme.darkPink,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("state") : null,
        ),
        ProfileFieldDisplay(
          label: 'Country',
          value: country,
          icon: Icons.flag,
          iconColor: ProfileTheme.darkPink,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("country") : null,
        ),
        ProfileFieldDisplay(
          label: 'Preferred Distance',
          value: locationPreference != null ? '$locationPreference km' : null,
          icon: Icons.gps_fixed,
          iconColor: ProfileTheme.darkPink,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("distance") : null,
          customValueWidget: locationPreference != null ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${locationPreference} km', style: Theme.of(context).textTheme.titleSmall),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: ProfileTheme.darkPink,
                  inactiveTrackColor: ProfileTheme.darkPurple.withValues(alpha: 0.3),
                  thumbColor: ProfileTheme.darkPink,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: locationPreference?.toDouble() ?? 1.0,
                  min: 1,
                  max: 300,
                  divisions: 30,
                  onChanged: editable ? (val) {} : null,
                ),
              ),
            ],
          ) : null,
          showDivider: false,
        ),
      ],
    );
  }
}