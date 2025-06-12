import 'package:flutter/material.dart';
import '../../theme/setup_profile_theme.dart';
import '../../stepmodel/step9_viewmodel.dart';

class InterestsLanguagesHeader extends StatelessWidget {
  const InterestsLanguagesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Your Interests & Languages',
                style: ProfileTheme.getTitleStyle(context).copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us match you with like-minded people.',
          style: ProfileTheme.getDescriptionStyle(context).copyWith(
            fontSize: 14,
            height: 1.4,
            color: const Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Fields marked with * are required.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9C27B0),
          ),
        ),
      ],
    );
  }
}

class InterestsLanguagesLoadingState extends StatelessWidget {
  const InterestsLanguagesLoadingState({super.key});

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
              'Loading interests and languages...',
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

class LanguageSelector extends StatefulWidget {
  final Step9ViewModel step9ViewModel;

  const LanguageSelector({super.key, required this.step9ViewModel});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _selectLanguage(String id, String name) {
    final currentSelected = widget.step9ViewModel.selectedLanguageIds ?? [];
    if (currentSelected.contains(id)) {
      currentSelected.remove(id);
    } else {
      currentSelected.add(id);
    }
    widget.step9ViewModel.setSelectedLanguageIds(currentSelected);
  }

  String _getDisplayText() {
    final selected = widget.step9ViewModel.selectedLanguageIds ?? [];
    if (selected.isEmpty) {
      return 'Select languages...';
    } else if (selected.length == 1) {
      final option = widget.step9ViewModel.languageOptions.firstWhere(
            (lang) => lang['value'] == selected.first,
        orElse: () => {'value': '', 'label': 'Unknown'},
      );
      return option['label'] ?? 'Unknown';
    } else {
      return '${selected.length} languages selected';
    }
  }

  String _getLanguageFlag(String label) {
    switch (label.toLowerCase()) {
      case 'english': return '🇺🇸';
      case 'spanish': return '🇪🇸';
      case 'french': return '🇫🇷';
      case 'german': return '🇩🇪';
      case 'chinese': return '🇨🇳';
      case 'japanese': return '🇯🇵';
      case 'korean': return '🇰🇷';
      case 'italian': return '🇮🇹';
      case 'portuguese': return '🇵🇹';
      case 'russian': return '🇷🇺';
      case 'vietnamese': return '🇻🇳';
      case 'thai': return '🇹🇭';
      case 'arabic': return '🇸🇦';
      case 'hindi': return '🇮🇳';
      default: return '🌐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = widget.step9ViewModel.selectedLanguageIds?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Languages you speak',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: hasSelection
                    ? const Color(0xFFD81B60).withAlpha(25)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasSelection ? const Color(0xFFD81B60) : const Color(0xFFBA68C8),
                  width: hasSelection ? 2.0 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    color: hasSelection ? const Color(0xFFD81B60) : const Color(0xFFBA68C8),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getDisplayText(),
                      style: TextStyle(
                        fontSize: 16,
                        color: hasSelection ? const Color(0xFF424242) : const Color(0xFFBA68C8),
                        fontWeight: hasSelection ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFFD81B60),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),

        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: widget.step9ViewModel.languageOptions.length,
                itemBuilder: (context, index) {
                  final option = widget.step9ViewModel.languageOptions[index];
                  final isSelected = widget.step9ViewModel.selectedLanguageIds?.contains(option['value']) ?? false;
                  return _buildLanguageOption(option, isSelected);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(Map<String, String> option, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectLanguage(option['value']!, option['label']!),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD81B60).withAlpha(25) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFD81B60).withValues(alpha: 0.1)
                      : const Color(0xFFBA68C8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getLanguageFlag(option['label']!),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option['label']!,
                  style: TextStyle(
                    fontSize: 15,
                    color: isSelected ? const Color(0xFFD81B60) : const Color(0xFF424242),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                    Icons.check_circle,
                    color: Color(0xFFD81B60),
                    size: 18
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewLanguageCheckbox extends StatelessWidget {
  final Step9ViewModel step9ViewModel;

  const NewLanguageCheckbox({super.key, required this.step9ViewModel});

  @override
  Widget build(BuildContext context) {
    final isChecked = step9ViewModel.interestedInNewLanguage ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isChecked
            ? const Color(0xFFD81B60).withAlpha(25)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked ? const Color(0xFFD81B60) : const Color(0xFFE0E0E0),
          width: isChecked ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: isChecked,
              onChanged: (value) => step9ViewModel.setInterestedInNewLanguage(value ?? false),
              activeColor: const Color(0xFFD81B60),
              checkColor: Colors.white,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Interested in learning new languages?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isChecked ? const Color(0xFFD81B60) : const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InterestSelector extends StatelessWidget {
  final Step9ViewModel step9ViewModel;

  const InterestSelector({super.key, required this.step9ViewModel});

  Map<String, dynamic> _getInterestData(String label) {
    switch (label.toLowerCase()) {
      case 'art & design':
      case 'art and design':
        return {'icon': Icons.palette, 'color': const Color(0xFFFF9800)};
      case 'cooking & food':
      case 'cooking and food':
        return {'icon': Icons.restaurant, 'color': const Color(0xFFE91E63)};
      case 'fitness & sports':
      case 'fitness and sports':
        return {'icon': Icons.fitness_center, 'color': const Color(0xFF2196F3)};
      case 'gaming':
        return {'icon': Icons.games, 'color': const Color(0xFF9C27B0)};
      case 'movies & tv':
      case 'movies and tv':
        return {'icon': Icons.movie, 'color': const Color(0xFF4CAF50)};
      case 'music':
        return {'icon': Icons.music_note, 'color': const Color(0xFF03A9F4)};
      case 'nature & outdoor':
      case 'nature and outdoor':
        return {'icon': Icons.nature, 'color': const Color(0xFF795548)};
      case 'reading':
        return {'icon': Icons.book, 'color': const Color(0xFF3F51B5)};
      case 'travel':
        return {'icon': Icons.flight, 'color': const Color(0xFF00BCD4)};
      case 'volunteering':
        return {'icon': Icons.volunteer_activism, 'color': const Color(0xFFE91E63)};
      default:
        return {'icon': Icons.interests, 'color': const Color(0xFF666666)};
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 48.0;
    final chipWidth = (screenWidth - horizontalPadding - 12) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Interests *',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),

        // Use SingleChildScrollView only for interests area to allow vertical scroll
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 6,
              runSpacing: 10,
              children: step9ViewModel.interestOptions.map((interest) {
                final isSelected = step9ViewModel.selectedInterestIds?.contains(interest['value']) ?? false;
                final interestData = _getInterestData(interest['label']!);

                return SizedBox(
                  width: chipWidth,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final currentSelected = step9ViewModel.selectedInterestIds ?? [];
                        if (isSelected) {
                          currentSelected.remove(interest['value']);
                        } else {
                          currentSelected.add(interest['value']!);
                        }
                        step9ViewModel.setSelectedInterestIds(currentSelected);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFD81B60)
                                : const Color(0xFFBA68C8),
                            width: isSelected ? 2.0 : 1.2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? const Color(0xFFD81B60).withAlpha(50)
                              : Colors.white.withAlpha(240),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: const Color(0xFFD81B60).withAlpha(40),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: (interestData['color'] as Color).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                interestData['icon'] as IconData,
                                color: interestData['color'] as Color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                interest['label']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFFD81B60)
                                      : const Color(0xFF424242),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (isSelected)
                              const Padding(
                                padding: EdgeInsets.only(left: 4.0),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFD81B60),
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}