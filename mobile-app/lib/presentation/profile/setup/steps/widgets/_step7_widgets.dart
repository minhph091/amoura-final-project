import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/setup_profile_theme.dart';
import '../../stepmodel/step7_viewmodel.dart';
import '../../../../shared/widgets/profile_option_selector.dart';
import '../../../../shared/widgets/custom_dropdown.dart';

class JobEducationHeader extends StatelessWidget {
  const JobEducationHeader({super.key});
  
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
                  colors: [Color(0xFF6B73FF), Color(0xFF9B59B6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B73FF).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.work_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Your Career & Education',
                style: ProfileTheme.getTitleStyle(context)?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF6B73FF), Color(0xFF9B59B6)],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Share your professional journey to connect with like-minded people 💼',
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

class JobEducationLoadingState extends StatelessWidget {
  const JobEducationLoadingState({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6B73FF).withOpacity(0.1),
              const Color(0xFF9B59B6).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B73FF)),
              strokeWidth: 3,
            ),
            SizedBox(height: 12),
            Text(
              'Loading career options...',
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

class JobIndustrySelector extends StatelessWidget {
  final Step7ViewModel step7ViewModel;
  final Function(bool)? onToggleExpanded;

  const JobIndustrySelector({
    super.key, 
    required this.step7ViewModel,
    this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Industry',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        CustomDropdown(
          options: step7ViewModel.jobIndustryOptions.map((opt) => {
            'value': opt['value']!,
            'label': opt['label']!,
            'icon': _getJobIndustryIcon(opt['label']!).codePoint.toString(),
            'color': _getJobIndustryColor(opt['label']!).value.toString(),
          }).toList(),
          value: step7ViewModel.jobIndustryId,
          onChanged: (value) {
            if (value != null) {
              final option = step7ViewModel.jobIndustryOptions.firstWhere(
                (opt) => opt['value'] == value,
                orElse: () => {'value': '', 'label': ''},
              );
              step7ViewModel.setJobIndustry(value, option['label']!);
            }
          },
        ),
      ],
    );
  }

  IconData _getJobIndustryIcon(String label) {
    switch (label.toLowerCase()) {
      case 'art/creative': return Icons.brush;
      case 'education/training': return Icons.psychology;
      case 'engineering/architecture': return Icons.architecture;
      case 'finance/accounting': return Icons.attach_money;
      case 'healthcare/medical': return Icons.medical_services;
      case 'hospitality/tourism': return Icons.hotel;
      case 'information technology': return Icons.developer_mode;
      case 'legal/law': return Icons.balance;
      case 'manufacturing/production': return Icons.precision_manufacturing;
      case 'media/communications': return Icons.mic;
      case 'retail/sales': return Icons.shopping_cart;
      case 'science/research': return Icons.biotech;
      case 'transportation/logistics': return Icons.local_shipping;
      case 'other': return Icons.business_center;
      default: return Icons.work_outline;
    }
  }

  Color _getJobIndustryColor(String label) {
    switch (label.toLowerCase()) {
      case 'art/creative': return const Color(0xFFE91E63);
      case 'education/training': return const Color(0xFF4CAF50);
      case 'engineering/architecture': return const Color(0xFF2196F3);
      case 'finance/accounting': return const Color(0xFF4CAF50);
      case 'healthcare/medical': return const Color(0xFFE91E63);
      case 'hospitality/tourism': return const Color(0xFF00BCD4);
      case 'information technology': return const Color(0xFF6B73FF);
      case 'legal/law': return const Color(0xFF795548);
      case 'manufacturing/production': return const Color(0xFF607D8B);
      case 'media/communications': return const Color(0xFFFF9800);
      case 'retail/sales': return const Color(0xFF9C27B0);
      case 'science/research': return const Color(0xFF3F51B5);
      case 'transportation/logistics': return const Color(0xFF795548);
      case 'other': return const Color(0xFF607D8B);
      default: return const Color(0xFF666666);
    }
  }
}

class EducationLevelSelector extends StatelessWidget {
  final Step7ViewModel step7ViewModel;
  final Function(bool)? onToggleExpanded;

  const EducationLevelSelector({
    super.key, 
    required this.step7ViewModel,
    this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Education Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        CustomDropdown(
          options: step7ViewModel.educationLevelOptions.map((opt) => {
            'value': opt['value']!,
            'label': opt['label']!,
            'icon': _getEducationIcon(opt['label']!).codePoint.toString(),
            'color': _getEducationColor(opt['label']!).value.toString(),
          }).toList(),
          value: step7ViewModel.educationLevelId,
          onChanged: (value) {
            if (value != null) {
              final option = step7ViewModel.educationLevelOptions.firstWhere(
                (opt) => opt['value'] == value,
                orElse: () => {'value': '', 'label': ''},
              );
              step7ViewModel.setEducationLevel(value, option['label']!);
            }
          },
        ),
      ],
    );
  }

  IconData _getEducationIcon(String label) {
    switch (label.toLowerCase()) {
      case 'high school': return Icons.grade;
      case 'bachelor\'s degree': return Icons.school;
      case 'master\'s degree': return Icons.auto_awesome;
      case 'doctorate/phd': return Icons.emoji_events;
      case 'trade school': return Icons.handyman;
      case 'associate degree': return Icons.assignment;
      case 'prefer not to say': return Icons.help_outline;
      default: return Icons.school_outlined;
    }
  }

  Color _getEducationColor(String label) {
    switch (label.toLowerCase()) {
      case 'high school': return const Color(0xFF4CAF50);
      case 'bachelor\'s degree': return const Color(0xFF2196F3);
      case 'master\'s degree': return const Color(0xFF9C27B0);
      case 'doctorate/phd': return const Color(0xFFE91E63);
      case 'trade school': return const Color(0xFFFF9800);
      case 'associate degree': return const Color(0xFF00BCD4);
      case 'prefer not to say': return const Color(0xFF9E9E9E);
      default: return const Color(0xFF666666);
    }
  }
}

class DropoutSwitch extends StatelessWidget {
  final Step7ViewModel step7ViewModel;

  const DropoutSwitch({super.key, required this.step7ViewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (step7ViewModel.dropOut ?? false)
              ? const Color(0xFFFF9800)
              : const Color(0xFFE0E0E0),
          width: (step7ViewModel.dropOut ?? false) ? 2 : 1,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (step7ViewModel.dropOut ?? false)
                  ? const Color(0xFFFF9800).withOpacity(0.1)
                  : const Color(0xFFE0E0E0).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.remove_circle_outline,
              color: (step7ViewModel.dropOut ?? false)
                  ? const Color(0xFFFF9800)
                  : const Color(0xFF666666),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'I didn\'t complete my education',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: (step7ViewModel.dropOut ?? false)
                    ? const Color(0xFFFF9800)
                    : const Color(0xFF333333),
              ),
            ),
          ),
          Switch(
            value: step7ViewModel.dropOut ?? false,
            onChanged: (value) => step7ViewModel.setDropOut(value),
            activeColor: const Color(0xFFFF9800),
            activeTrackColor: const Color(0xFFFF9800).withOpacity(0.3),
            inactiveThumbColor: const Color(0xFFE0E0E0),
            inactiveTrackColor: const Color(0xFFE0E0E0).withOpacity(0.5),
          ),
        ],
      ),
    );
  }
} 