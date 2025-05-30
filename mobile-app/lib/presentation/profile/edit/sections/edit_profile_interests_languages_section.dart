import 'package:flutter/material.dart';
import '../../../../core/constants/profile/language_constants.dart';
import '../../../../core/constants/profile/interest_constants.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../../setup/theme/setup_profile_theme.dart';
import '../edit_profile_viewmodel.dart';

class EditProfileInterestsLanguagesSection extends StatefulWidget {
  final EditProfileViewModel viewModel;

  const EditProfileInterestsLanguagesSection({
    super.key,
    required this.viewModel,
  });

  @override
  State<EditProfileInterestsLanguagesSection> createState() => _EditProfileInterestsLanguagesSectionState();
}

class _EditProfileInterestsLanguagesSectionState extends State<EditProfileInterestsLanguagesSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Interests & Languages', style: ProfileTheme.getSubtitleStyle(context)),
        const SizedBox(height: 6),
        Text('This helps us match you with like-minded people.',
            style: ProfileTheme.getDescriptionStyle(context)),
        const SizedBox(height: 6),
        Text('Fields marked with * are required.',
            style: ProfileTheme.getDescriptionStyle(context)),
        const SizedBox(height: 16),

        // Languages Selection
        Text('Languages you speak', style: ProfileTheme.getLabelStyle(context)),
        const SizedBox(height: 8),
        _buildLanguageDropdown(),

        const SizedBox(height: 16),

        // New Languages Interest Toggle
        Row(
          children: [
            Expanded(
              child: Text(
                'Interested in learning new languages?',
                style: ProfileTheme.getInputTextStyle(context),
              ),
            ),
            Switch(
              value: widget.viewModel.interestedInNewLanguage ?? false,
              onChanged: (val) {
                setState(() => widget.viewModel.updateInterestedInNewLanguage(val));
              },
              activeColor: ProfileTheme.darkPink,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Interests Selection (Required)
        Text('Your Interests *', style: ProfileTheme.getLabelStyle(context)),
        const SizedBox(height: 8),
        _buildInterestsGrid(),

        if ((widget.viewModel.selectedInterestIds?.isEmpty ?? true))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one interest',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: ProfileTheme.lightPurple,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: ProfileTheme.darkPink),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(12),
          hint: Row(
            children: [
              Icon(Icons.language, color: ProfileTheme.darkPink),
              const SizedBox(width: 10),
              Text('Select languages...', style: TextStyle(color: ProfileTheme.lightPurple)),
            ],
          ),
          value: null, // Always show hint since we're using multi-select
          onChanged: (String? newValue) {
            // This is handled by our custom dropdown menu
          },
          items: null,
          onTap: () {
            _showLanguagesDialog();
          },
        ),
      ),
    );
  }

  void _showLanguagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Languages', style: TextStyle(color: ProfileTheme.darkPurple)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languageOptions.length,
            itemBuilder: (ctx, index) {
              final option = languageOptions[index];
              final isSelected = widget.viewModel.selectedLanguageIds?.contains(option['value']) ?? false;

              return CheckboxListTile(
                title: Text(option['label'] as String),
                value: isSelected,
                activeColor: ProfileTheme.darkPink,
                onChanged: (selected) {
                  setState(() {
                    widget.viewModel.updateLanguage(
                      option['value'] as String,
                      selected ?? false,
                    );
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Done', style: TextStyle(color: ProfileTheme.darkPink)),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 items per row
        childAspectRatio: 2.5, // Adjust based on your design
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: interestOptions.length,
      itemBuilder: (context, index) {
        final option = interestOptions[index];
        final isSelected = widget.viewModel.selectedInterestIds?.contains(option['value']) ?? false;

        return _InterestItem(
          label: option['label'] as String,
          icon: option['icon'] as IconData,
          isSelected: isSelected,
          onToggle: (selected) {
            setState(() {
              widget.viewModel.updateInterest(
                option['value'] as String,
                selected,
              );
            });
          },
        );
      },
    );
  }
}

class _InterestItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Function(bool) onToggle;

  const _InterestItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onToggle(!isSelected),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? ProfileTheme.darkPink : ProfileTheme.lightPurple,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? ProfileTheme.darkPink.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? ProfileTheme.darkPink : ProfileTheme.lightPurple,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? ProfileTheme.darkPink : ProfileTheme.darkPurple,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: ProfileTheme.darkPink,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}