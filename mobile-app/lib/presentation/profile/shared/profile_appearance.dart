import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';
import 'profile_field_display.dart';
import 'theme/profile_theme.dart';

class ProfileAppearance extends StatelessWidget {
  final String? bodyType;
  final int? height;
  final bool editable;
  final void Function(String field)? onEdit;

  const ProfileAppearance({
    super.key,
    this.bodyType,
    this.height,
    this.editable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileFieldDisplay(
          label: 'Body Type',
          value: bodyType,
          icon: Icons.accessibility_new,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("bodyType") : null,
          iconColor: ProfileTheme.darkPink,
        ),
        ProfileFieldDisplay(
          label: 'Height',
          value: height != null ? '$height cm' : null,
          icon: Icons.height,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("height") : null,
          iconColor: ProfileTheme.darkPink,
          showDivider: false,
          customValueWidget: height != null ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$height cm', style: Theme.of(context).textTheme.titleSmall),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: ProfileTheme.darkPink,
                  inactiveTrackColor: ProfileTheme.darkPurple.withOpacity(0.3),
                  thumbColor: ProfileTheme.darkPink,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: height!.toDouble(),
                  min: 100,
                  max: 250,
                  divisions: 150,
                  onChanged: editable ? (val) {} : null,
                ),
              ),
            ],
          ) : null,
        ),
      ],
    );
  }
}