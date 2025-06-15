import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/setup_profile_theme.dart';
import '../../stepmodel/step6_viewmodel.dart';

class AppearanceHeader extends StatelessWidget {
  const AppearanceHeader({super.key});
  
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
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.accessibility_new,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Your Appearance',
                style: ProfileTheme.getTitleStyle(context)?.copyWith(
                  fontSize: 26,
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
        const SizedBox(height: 12),
        Text(
          'Help others get to know the beautiful you better ✨',
          style: ProfileTheme.getDescriptionStyle(context)?.copyWith(
            fontSize: 15,
            height: 1.4,
            color: const Color(0xFF666666),
          ),
        ),
      ],
    );
  }
}

class AppearanceLoadingState extends StatelessWidget {
  const AppearanceLoadingState({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF9C27B0).withOpacity(0.1),
              const Color(0xFFE91E63).withOpacity(0.1),
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
              'Loading appearance options...',
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

class BodyTypeSelector extends StatefulWidget {
  final Step6ViewModel step6ViewModel;

  const BodyTypeSelector({super.key, required this.step6ViewModel});

  @override
  State<BodyTypeSelector> createState() => _BodyTypeSelectorState();
}

class _BodyTypeSelectorState extends State<BodyTypeSelector> 
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

  void _selectBodyType(String id, String name) {
    widget.step6ViewModel.setBodyType(id, name);
    // Auto collapse after selection
    _toggleExpanded();
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = widget.step6ViewModel.bodyTypeOptions.firstWhere(
      (option) => option['value'] == widget.step6ViewModel.bodyTypeId,
      orElse: () => {'value': '', 'label': 'Select Body Type'},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Body Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        
        // Collapsed/Selected State
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: widget.step6ViewModel.bodyTypeId != null
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF9C27B0).withOpacity(0.1),
                          const Color(0xFFE91E63).withOpacity(0.1),
                        ],
                      )
                    : null,
                color: widget.step6ViewModel.bodyTypeId == null 
                    ? Colors.white : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.step6ViewModel.bodyTypeId != null
                      ? const Color(0xFF9C27B0)
                      : const Color(0xFFE0E0E0),
                  width: widget.step6ViewModel.bodyTypeId != null ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (widget.step6ViewModel.bodyTypeId != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getBodyTypeIcon(selectedOption['label']!),
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.category,
                        color: Color(0xFF666666),
                        size: 20,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedOption['label']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.step6ViewModel.bodyTypeId != null
                            ? const Color(0xFF9C27B0)
                            : const Color(0xFF666666),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: widget.step6ViewModel.bodyTypeId != null
                          ? const Color(0xFF9C27B0)
                          : const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Expanded Options
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(
              maxHeight: 200, // Limit height to prevent overflow
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.step6ViewModel.bodyTypeOptions.length,
                itemBuilder: (context, index) {
                  final option = widget.step6ViewModel.bodyTypeOptions[index];
                  final isSelected = widget.step6ViewModel.bodyTypeId == option['value'];
                  return BodyTypeOption(
                    option: option,
                    isSelected: isSelected,
                    onTap: () => _selectBodyType(option['value']!, option['label']!),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getBodyTypeIcon(String label) {
    switch (label.toLowerCase()) {
      case 'slim':
      case 'skinny':
        return Icons.person_outline;
      case 'average':
      case 'normal':
        return Icons.person;
      case 'athletic':
      case 'fit':
        return Icons.fitness_center;
      case 'muscular':
      case 'strong':
        return Icons.sports_gymnastics;
      case 'curvy':
      case 'voluptuous':
        return Icons.favorite;
      case 'plus size':
      case 'full figured':
        return Icons.sentiment_satisfied;
      default:
        return Icons.help_outline;
    }
  }
}

class BodyTypeOption extends StatelessWidget {
  final Map<String, String> option;
  final bool isSelected;
  final VoidCallback onTap;

  const BodyTypeOption({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  Map<String, dynamic> _getBodyTypeData(String label) {
    switch (label.toLowerCase()) {
      case 'slim':
      case 'skinny':
        return {
          'icon': Icons.person_outline,
          'color': const Color(0xFF4CAF50),
        };
      case 'average':
      case 'normal':
        return {
          'icon': Icons.person,
          'color': const Color(0xFF2196F3),
        };
      case 'athletic':
      case 'fit':
        return {
          'icon': Icons.fitness_center,
          'color': const Color(0xFFFF9800),
        };
      case 'muscular':
      case 'strong':
        return {
          'icon': Icons.sports_gymnastics,
          'color': const Color(0xFFE91E63),
        };
      case 'curvy':
      case 'voluptuous':
        return {
          'icon': Icons.favorite,
          'color': const Color(0xFF9C27B0),
        };
      case 'plus size':
      case 'full figured':
        return {
          'icon': Icons.sentiment_satisfied,
          'color': const Color(0xFF795548),
        };
      default:
        return {
          'icon': Icons.help_outline,
          'color': const Color(0xFF607D8B),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyTypeData = _getBodyTypeData(option['label']!);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF9C27B0).withOpacity(0.05) : null,
            border: const Border(
              bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (bodyTypeData['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  bodyTypeData['icon'] as IconData,
                  color: bodyTypeData['color'] as Color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option['label']!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? const Color(0xFF9C27B0) : const Color(0xFF333333),
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF9C27B0),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeightSelector extends StatelessWidget {
  final Step6ViewModel step6ViewModel;

  const HeightSelector({super.key, required this.step6ViewModel});

  @override
  Widget build(BuildContext context) {
    final currentHeight = step6ViewModel.height ?? 170;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Height',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF9C27B0).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Numeric input field
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: currentHeight.toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your height',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF9C27B0), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        isDense: true,
                        suffixIcon: Container(
                          padding: const EdgeInsets.only(right: 12),
                          child: const Text(
                            'cm',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF666666),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          int? heightValue = int.tryParse(value);
                          if (heightValue != null && heightValue >= 140 && heightValue <= 220) {
                            step6ViewModel.setHeight(heightValue);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Height range indicators
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Valid range: 140-220 cm',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
