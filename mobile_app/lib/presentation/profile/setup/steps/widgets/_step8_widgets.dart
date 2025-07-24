// lib/presentation/profile/setup/steps/widgets/_step8_widgets.dart
import 'package:flutter/material.dart';
import '../../theme/setup_profile_theme.dart';
import '../../stepmodel/step8_viewmodel.dart';
import '../../../../../config/language/app_localizations.dart';

class LifestyleHeader extends StatelessWidget {
  const LifestyleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.translate('step8_title'),
          style: ProfileTheme.getTitleStyle(
            context,
          ).copyWith(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          localizations.translate('step8_description'),
          style: ProfileTheme.getDescriptionStyle(
            context,
          ).copyWith(fontSize: 15, height: 1.4, color: const Color(0xFF666666)),
        ),
      ],
    );
  }
}

class LifestyleLoadingState extends StatelessWidget {
  const LifestyleLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF9C27B0).withValues(alpha: 0.1),
              const Color(0xFFE91E63).withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
              strokeWidth: 3,
            ),
            SizedBox(height: 12),
            Text(
              'Loading lifestyle options...',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrinkStatusSelector extends StatelessWidget {
  final Step8ViewModel step8ViewModel;

  const DrinkStatusSelector({super.key, required this.step8ViewModel});

  Map<String, dynamic> _getDrinkIconData(String label) {
    switch (label.toLowerCase()) {
      case 'never':
      case 'no':
        return {'icon': '⛔', 'color': const Color(0xFF78909C)};
      case 'rarely':
      case 'sometimes':
        return {'icon': '🍺', 'color': const Color(0xFF4CAF50)};
      case 'socially':
      case 'social':
        return {'icon': '🥂', 'color': const Color(0xFF2196F3)};
      case 'regularly':
      case 'often':
        return {'icon': '🍷', 'color': const Color(0xFFFF9800)};
      case 'frequently':
      case 'daily':
        return {'icon': '🍹', 'color': const Color(0xFFE91E63)};
      default:
        return {'icon': '🥃', 'color': const Color(0xFF666666)};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🍻', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Text(
                'Do you drink?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: false,
                itemHeight: 48,
                value:
                    step8ViewModel.drinkStatusId?.isNotEmpty == true
                        ? step8ViewModel.drinkStatusId
                        : null,
                isExpanded: true,
                hint: const Text(
                  'Select drinking preference',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFE91E63),
                  size: 26,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D2D2D),
                  fontWeight: FontWeight.w600,
                ),
                items:
                    step8ViewModel.drinkStatusOptions.map((option) {
                      final iconData = _getDrinkIconData(option['label']!);
                      final isSelected =
                          step8ViewModel.drinkStatusId == option['value'];
                      return DropdownMenuItem<String>(
                        value: option['value'],
                        child: Row(
                          children: [
                            Text(
                              iconData['icon'],
                              style: TextStyle(
                                fontSize: 24,
                                color: iconData['color'],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              option['label']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? Color(0xFFE91E63)
                                        : Color(0xFF2D2D2D),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final option = step8ViewModel.drinkStatusOptions.firstWhere(
                      (opt) => opt['value'] == value,
                      orElse: () => {'value': '', 'label': ''},
                    );
                    step8ViewModel.setDrinkStatus(value, option['label']!);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SmokeStatusSelector extends StatelessWidget {
  final Step8ViewModel step8ViewModel;

  const SmokeStatusSelector({super.key, required this.step8ViewModel});

  Map<String, dynamic> _getSmokeIconData(String label) {
    switch (label.toLowerCase()) {
      case 'never':
      case 'no':
        return {'icon': '🚫', 'color': const Color(0xFF78909C)};
      case 'socially':
      case 'sometimes':
        return {'icon': '🚬', 'color': const Color(0xFF4CAF50)};
      case 'regularly':
      case 'often':
        return {'icon': '💨', 'color': const Color(0xFFE91E63)};
      case 'frequently':
      case 'daily':
        return {'icon': '🚭', 'color': const Color(0xFFFF9800)};
      default:
        return {'icon': '🚭', 'color': const Color(0xFF666666)};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚬', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Text(
                'Do you smoke?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: false,
                itemHeight: 48,
                value:
                    step8ViewModel.smokeStatusId?.isNotEmpty == true
                        ? step8ViewModel.smokeStatusId
                        : null,
                isExpanded: true,
                hint: const Text(
                  'Select smoking preference',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFE91E63),
                  size: 26,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D2D2D),
                  fontWeight: FontWeight.w600,
                ),
                items:
                    step8ViewModel.smokeStatusOptions.map((option) {
                      final iconData = _getSmokeIconData(option['label']!);
                      final isSelected =
                          step8ViewModel.smokeStatusId == option['value'];
                      return DropdownMenuItem<String>(
                        value: option['value'],
                        child: Row(
                          children: [
                            Text(
                              iconData['icon'],
                              style: TextStyle(
                                fontSize: 24,
                                color: iconData['color'],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              option['label']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? Color(0xFFE91E63)
                                        : Color(0xFF2D2D2D),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final option = step8ViewModel.smokeStatusOptions.firstWhere(
                      (opt) => opt['value'] == value,
                      orElse: () => {'value': '', 'label': ''},
                    );
                    step8ViewModel.setSmokeStatus(value, option['label']!);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PetSelector extends StatelessWidget {
  final Step8ViewModel step8ViewModel;

  const PetSelector({super.key, required this.step8ViewModel});

  Map<String, dynamic> _getPetData(String label) {
    switch (label.toLowerCase()) {
      case 'bird':
        return {'emoji': '🐦', 'color': const Color(0xFF4CAF50)};
      case 'cat':
        return {'emoji': '🐱', 'color': const Color(0xFFFF9800)};
      case 'dog':
        return {'emoji': '🐶', 'color': const Color(0xFF2196F3)};
      case 'fish':
        return {'emoji': '🐠', 'color': const Color(0xFF00BCD4)};
      case 'hamster':
        return {'emoji': '🐹', 'color': const Color(0xFFE91E63)};
      case 'horse':
        return {'emoji': '🐴', 'color': const Color(0xFF9C27B0)};
      case 'rabbit':
        return {'emoji': '🐰', 'color': const Color(0xFF4CAF50)};
      case 'reptile':
        return {'emoji': '🦎', 'color': const Color(0xFF795548)};
      case 'other':
        return {'emoji': '❓', 'color': const Color(0xFF607D8B)};
      default:
        return {'emoji': '🐾', 'color': const Color(0xFF607D8B)};
    }
  }

  @override
  Widget build(BuildContext context) {
    // 2 columns, rectangular, no scroll, fit all options
    final petOptions = step8ViewModel.petOptions;
    final int colCount = 2;
    final double itemHeight = 48;
    final double iconSize = 28;
    final double fontSize = 15;
    final double borderRadius = 12;
    final double borderWidth = 1.5;
    final double horizontalPadding = 6;
    final double verticalPadding = 6;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🐾', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            const Text(
              'Do you have pets?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            final double totalSpacing = 8 * (colCount - 1);
            final double itemWidth =
                (constraints.maxWidth - totalSpacing) / colCount;
            return Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(petOptions.length, (i) {
                    final pet = petOptions[i];
                    final isSelected =
                        step8ViewModel.selectedPets?.contains(pet['value']) ??
                        false;
                    final petData = _getPetData(pet['label']!);
                    return SizedBox(
                      width: itemWidth,
                      height: itemHeight,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            step8ViewModel.selectedPets ??= [];
                            if (isSelected) {
                              step8ViewModel.selectedPets!.remove(pet['value']);
                            } else {
                              step8ViewModel.selectedPets!.add(pet['value']!);
                            }
                            step8ViewModel.setSelectedPets(
                              step8ViewModel.selectedPets!,
                            );
                          },
                          borderRadius: BorderRadius.circular(borderRadius),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: verticalPadding,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    isSelected
                                        ? const Color(0xFFE91E63)
                                        : const Color(0xFFBA68C8),
                                width: isSelected ? 2.0 : borderWidth,
                              ),
                              borderRadius: BorderRadius.circular(borderRadius),
                              color:
                                  isSelected
                                      ? const Color(0xFFFFE3F0)
                                      : Colors.white,
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: const Color(
                                      0xFFE91E63,
                                    ).withValues(alpha: 0.13),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: (petData['color'] as Color)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    petData['emoji'] as String,
                                    style: TextStyle(fontSize: iconSize),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    pet['label']!,
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      color:
                                          isSelected
                                              ? const Color(0xFFE91E63)
                                              : const Color(0xFF424242),
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Color(0xFFE91E63),
                                      size: 18,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 2),
              ],
            );
          },
        ),
      ],
    );
  }
}
