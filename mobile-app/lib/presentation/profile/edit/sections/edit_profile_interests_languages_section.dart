import 'package:flutter/material.dart';
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
    final options = widget.viewModel.safeOptions(widget.viewModel.profileOptions?['languages']);
    final selectedLanguages = widget.viewModel.selectedLanguageIds?.map((id) {
      final option = options.firstWhere(
        (opt) => opt['value'] == id,
        orElse: () => {'label': 'Unknown', 'value': id},
      );
      return option['label'] as String;
    }).toList() ?? [];

    return InkWell(
      onTap: _showLanguagesDialog,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: ProfileTheme.lightPurple,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.language, color: ProfileTheme.darkPink),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedLanguages.isEmpty
                    ? 'Select languages...'
                    : selectedLanguages.join(', '),
                style: TextStyle(
                  color: selectedLanguages.isEmpty ? ProfileTheme.lightPurple : ProfileTheme.darkPurple,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: ProfileTheme.darkPink),
          ],
        ),
      ),
    );
  }

  void _showLanguagesDialog() {
    final options = widget.viewModel.safeOptions(widget.viewModel.profileOptions?['languages']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Languages', style: TextStyle(color: ProfileTheme.darkPurple)),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (ctx, index) {
                final option = options[index];
                final isSelected = widget.viewModel.selectedLanguageIds?.contains(option['value']) ?? false;

                return CheckboxListTile(
                  title: Row(
                    children: [
                      if (option['iconUrl'] != null)
                        Image.network(
                          option['iconUrl'] as String,
                          width: 24,
                          height: 16,
                          errorBuilder: (context, error, stackTrace) => 
                            Icon(Icons.language, color: option['color'] as Color),
                        ),
                      const SizedBox(width: 8),
                      Text(option['label'] as String),
                    ],
                  ),
                  value: isSelected,
                  activeColor: ProfileTheme.darkPink,
                  onChanged: (selected) {
                    setStateDialog(() {
                      widget.viewModel.updateLanguage(
                        option['value'],
                        selected ?? false,
                      );
                    });
                  },
                );
              },
            ),
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
    final options = widget.viewModel.safeOptions(widget.viewModel.profileOptions?['interests']);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 items per row
        childAspectRatio: 2.5, // Adjust based on your design
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = widget.viewModel.selectedInterestIds?.contains(option['value']) ?? false;

        return _InterestItem(
          label: option['label'] as String,
          icon: option['icon'] as IconData?,
          isSelected: isSelected,
          onToggle: (selected) {
            setState(() {
              widget.viewModel.updateInterest(
                option['value'],
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
  final IconData? icon;
  final bool isSelected;
  final Function(bool) onToggle;

  const _InterestItem({
    required this.label,
    this.icon,
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
          color: isSelected ? ProfileTheme.darkPink.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  if (icon != null)
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