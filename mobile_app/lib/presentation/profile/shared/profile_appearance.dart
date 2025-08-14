import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';
import 'profile_field_display.dart';

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
    // Log the received data for debugging
    debugPrint('ProfileAppearance - Received Data:');
    debugPrint('Body Type: $bodyType');
    debugPrint('Height: $height');

    // Normalize height for display / slider: convert inches (<100) to cm and clamp to 100-250
    int? displayHeight;
    if (height != null) {
      final h = height!;
      final cm = h < 100 ? (h * 2.54).round() : h;
      displayHeight = cm.clamp(100, 250);
    }

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
          value: displayHeight != null ? '$displayHeight cm' : null,
          icon: Icons.height,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("height") : null,
          iconColor: ProfileTheme.darkPink,
          showDivider: false,
          customValueWidget: displayHeight != null ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$displayHeight cm', style: Theme.of(context).textTheme.titleSmall),
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
                  value: displayHeight!.toDouble(),
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

