import 'package:flutter/material.dart';
import '../../../../core/constants/profile/smoke_drink_constants.dart';
import '../../../../core/constants/profile/pet_constants.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../../setup/theme/setup_profile_theme.dart';
import '../../theme/profile_theme.dart';
import '../edit_profile_viewmodel.dart';

class EditProfileLifestyleSection extends StatefulWidget {
  final EditProfileViewModel viewModel;

  const EditProfileLifestyleSection({
    super.key,
    required this.viewModel,
  });

  @override
  State<EditProfileLifestyleSection> createState() => _EditProfileLifestyleSectionState();
}

class _EditProfileLifestyleSectionState extends State<EditProfileLifestyleSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Lifestyle', style: ProfileTheme.getSubtitleStyle(context)),
        const SizedBox(height: 6),
        Text('Tell us about your lifestyle and pets.',
            style: ProfileTheme.getDescriptionStyle(context)),
        const SizedBox(height: 16),

        // Drink Status Dropdown
        ProfileOptionSelector(
          options: drinkOptions,
          selectedValue: widget.viewModel.drinkStatus,
          onChanged: (value, selected) {
            if (selected) {
              setState(() => widget.viewModel.updateDrinkStatus(value));
            }
          },
          labelText: 'Do you drink?',
          labelStyle: ProfileTheme.getLabelStyle(context),
          isDropdown: true,
        ),

        const SizedBox(height: 18),

        // Smoke Status Dropdown
        ProfileOptionSelector(
          options: smokeOptions,
          selectedValue: widget.viewModel.smokeStatus,
          onChanged: (value, selected) {
            if (selected) {
              setState(() => widget.viewModel.updateSmokeStatus(value));
            }
          },
          labelText: 'Do you smoke?',
          labelStyle: ProfileTheme.getLabelStyle(context),
          isDropdown: true,
        ),

        const SizedBox(height: 18),

        // Pet Selection Label
        Text('Do you have pets?', style: ProfileTheme.getLabelStyle(context)),

        const SizedBox(height: 8),

        // Pet Grid Layout - Fixed 2 columns
        _buildPetsGrid(),
      ],
    );
  }

  Widget _buildPetsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: petOptions.length,
      itemBuilder: (context, index) {
        final option = petOptions[index];
        final isSelected = widget.viewModel.selectedPets?.contains(option['value']) ?? false;

        return _buildPetItem(
          label: option['label'],
          icon: option['icon'],
          isSelected: isSelected,
          onToggle: () {
            setState(() {
              widget.viewModel.updatePet(option['value'], !isSelected);
            });
          },
        );
      },
    );
  }

  Widget _buildPetItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onToggle,
  }) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? ProfileTheme.darkPink : ProfileTheme.lightPurple,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? ProfileTheme.darkPink.withOpacity(0.1) : Colors.transparent,
        ),
        child: Stack(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? ProfileTheme.darkPink : ProfileTheme.lightPurple,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? ProfileTheme.darkPink : ProfileTheme.darkPurple,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: ProfileTheme.darkPink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}