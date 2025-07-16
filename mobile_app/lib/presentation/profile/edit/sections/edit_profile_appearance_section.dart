import 'package:flutter/material.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../../setup/theme/setup_profile_theme.dart';
import '../../../../config/language/app_localizations.dart';
import '../edit_profile_viewmodel.dart';

class EditProfileAppearanceSection extends StatefulWidget {
  final EditProfileViewModel viewModel;

  const EditProfileAppearanceSection({super.key, required this.viewModel});

  @override
  State<EditProfileAppearanceSection> createState() =>
      _EditProfileAppearanceSectionState();
}

class _EditProfileAppearanceSectionState
    extends State<EditProfileAppearanceSection> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Appearance',
              style: ProfileTheme.getSubtitleStyle(context),
            ),
            const SizedBox(height: 6),
            Text(
              'Let others know more about your look.',
              style: ProfileTheme.getDescriptionStyle(context),
            ),
            const SizedBox(height: 16),

            // Body Type Dropdown
            ProfileOptionSelector(
              options: widget.viewModel.safeOptions(
                widget.viewModel.profileOptions?['bodyTypes'],
              ),
              selectedValue: widget.viewModel.bodyType,
              onChanged: (value, selected) {
                if (selected) {
                  setState(() => widget.viewModel.updateBodyType(value));
                }
              },
              labelText: AppLocalizations.of(context).translate('body_type'),
              labelStyle: ProfileTheme.getLabelStyle(context),
              isDropdown: true,
            ),

            const SizedBox(height: 20),

            // Height Slider
            Text('Height (cm)', style: ProfileTheme.getLabelStyle(context)),

            Slider(
              value: (widget.viewModel.height ?? 170).toDouble(),
              min: 100,
              max: 250,
              divisions: 150,
              label: '${widget.viewModel.height ?? 170} cm',
              activeColor: ProfileTheme.darkPink,
              inactiveColor: ProfileTheme.darkPurple.withAlpha(77),
              onChanged:
                  (val) => setState(
                    () => widget.viewModel.updateHeight(val.round()),
                  ),
            ),

            Center(
              child: Text(
                '${widget.viewModel.height ?? 170} cm',
                style: ProfileTheme.getTitleStyle(
                  context,
                ).copyWith(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
