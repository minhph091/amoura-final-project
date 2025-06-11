import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/setup_profile_theme.dart';
import '../../stepmodel/step3_viewmodel.dart';

class OrientationHeader extends StatelessWidget {
  const OrientationHeader({super.key});
  
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
                  colors: [Color(0xFFFF6B9D), Color(0xFFFF8E8E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B9D).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Your Romantic Orientation',
                style: ProfileTheme.getTitleStyle(context)?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFFFF6B9D), Color(0xFFD81B60)],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Help us find your perfect match by sharing who makes your heart flutter 💕',
          style: ProfileTheme.getDescriptionStyle(context)?.copyWith(
            fontSize: 16,
            height: 1.5,
            color: const Color(0xFF666666),
          ),
        ),
      ],
    );
  }
}

class OrientationLoadingState extends StatelessWidget {
  const OrientationLoadingState({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B9D).withOpacity(0.1),
                  const Color(0xFFD81B60).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Preparing your options...',
            style: TextStyle(
              color: const Color(0xFF666666),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class OrientationErrorState extends StatelessWidget {
  final String errorMessage;

  const OrientationErrorState({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class OrientationEmptyState extends StatelessWidget {
  const OrientationEmptyState({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF666666).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              color: const Color(0xFF666666),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No orientation options available',
              style: TextStyle(
                color: const Color(0xFF666666),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrientationCards extends StatelessWidget {
  final Step3ViewModel step3ViewModel;

  const OrientationCards({super.key, required this.step3ViewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose what feels right for you:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 20),
        ...step3ViewModel.orientationOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = step3ViewModel.orientationId == option['value'];
          
          // Debug: Track selection state
          print('🎯 Option ${option['label']}: isSelected=$isSelected (orientationId=${step3ViewModel.orientationId}, optionValue=${option['value']})');
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: OrientationCard(
              option: option,
              isSelected: isSelected,
              onTap: () {
                if (option['value']!.isNotEmpty) {
                  step3ViewModel.setOrientation(option['value']!, option['label']!);
                }
              },
            ),
          ).animate(delay: Duration(milliseconds: (150 * index).toInt())).slideX(
            begin: 0.3,
            duration: const Duration(milliseconds: 500),
          ).fadeIn();
        }).toList(),
      ],
    );
  }
}

class OrientationCard extends StatelessWidget {
  final Map<String, String> option;
  final bool isSelected;
  final VoidCallback onTap;

  const OrientationCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  Map<String, dynamic> _getOrientationData(String label) {
    switch (label.toLowerCase()) {
      case 'straight':
        return {
          'icon': Icons.favorite,
          'primaryColor': const Color(0xFFFF6B9D),
          'secondaryColor': const Color(0xFFFF8E8E),
          'description': 'Attracted to people of the opposite gender',
        };
      case 'homosexual':
      case 'gay':
      case 'lesbian':
        return {
          'icon': Icons.diversity_1,
          'primaryColor': const Color(0xFF6B73FF),
          'secondaryColor': const Color(0xFF9B59B6),
          'description': 'Attracted to people of the same gender',
        };
      case 'bisexual':
        return {
          'icon': Icons.diversity_3,
          'primaryColor': const Color(0xFFE91E63),
          'secondaryColor': const Color(0xFF9C27B0),
          'description': 'Attracted to people of multiple genders',
        };
      case 'pansexual':
        return {
          'icon': Icons.palette,
          'primaryColor': const Color(0xFFFF9800),
          'secondaryColor': const Color(0xFFE91E63),
          'description': 'Attracted to people regardless of gender',
        };
      case 'asexual':
        return {
          'icon': Icons.self_improvement,
          'primaryColor': const Color(0xFF607D8B),
          'secondaryColor': const Color(0xFF9E9E9E),
          'description': 'Little to no sexual attraction to others',
        };
      default:
        return {
          'icon': Icons.help_outline,
          'primaryColor': const Color(0xFF9E9E9E),
          'secondaryColor': const Color(0xFFBDBDBD),
          'description': 'Tell us more about your orientation',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientationData = _getOrientationData(option['label']!);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          orientationData['primaryColor'] as Color,
                          orientationData['secondaryColor'] as Color,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white,
                          const Color(0xFFFAFAFA),
                        ],
                      ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? (orientationData['primaryColor'] as Color)
                      : const Color(0xFFE0E0E0),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: (orientationData['primaryColor'] as Color).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  if (!isSelected)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : (orientationData['primaryColor'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      orientationData['icon'] as IconData,
                      size: 32,
                      color: isSelected
                          ? Colors.white
                          : orientationData['primaryColor'] as Color,
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option['label']!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          orientationData['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? Colors.white.withOpacity(0.9)
                                : const Color(0xFF666666),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Selection Indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFFCCCCCC),
                      size: 24,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}