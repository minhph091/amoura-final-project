import 'package:flutter/material.dart';
import '../../theme/setup_profile_theme.dart';
import '../../stepmodel/step7_viewmodel.dart';
import '../../../../shared/widgets/custom_dropdown.dart';

class JobEducationHeader extends StatelessWidget {
  const JobEducationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Career & Education',
          style: ProfileTheme.getTitleStyle(context).copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Share your professional journey to connect with like-minded people 🧳',
          style: ProfileTheme.getDescriptionStyle(context).copyWith(
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
              const Color(0xFF6B73FF).withValues(alpha: 0.1),
              const Color(0xFF9B59B6).withValues(alpha: 0.1),
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

  String _getJobEmoji(String label) {
    switch (label.toLowerCase()) {
      case 'art/creative': return '🖌️';
      case 'education/training': return '📖';
      case 'engineering/architecture': return '🛠️';
      case 'finance/accounting': return '💹';
      case 'healthcare/medical': return '🩺';
      case 'hospitality/tourism': return '🛎️';
      case 'information technology': return '🖥️';
      case 'legal/law': return '⚖️';
      case 'manufacturing/production': return '🏭';
      case 'media/communications': return '📺';
      case 'retail/sales': return '🛍️';
      case 'science/research': return '🔬';
      case 'transportation/logistics': return '🚚';
      case 'other': return '🧩';
      default: return '🏢';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel = step7ViewModel.jobIndustryOptions.firstWhere(
      (option) => option['value'] == step7ViewModel.jobIndustryId,
      orElse: () => {'value': '', 'label': ''},
    )['label'] ?? '';
    final emoji = selectedLabel.isNotEmpty ? _getJobEmoji(selectedLabel) : '🏢';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Text('Job Industry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: false,
                itemHeight: 48,
                value: step7ViewModel.jobIndustryId?.isNotEmpty == true ? step7ViewModel.jobIndustryId : null,
                isExpanded: true,
                hint: const Text('Select job industry', style: TextStyle(fontSize: 15, color: Color(0xFF757575), fontWeight: FontWeight.w500)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B73FF), size: 26),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
                style: const TextStyle(fontSize: 16, color: Color(0xFF2D2D2D), fontWeight: FontWeight.w600),
                items: step7ViewModel.jobIndustryOptions.map((option) {
                  final isSelected = step7ViewModel.jobIndustryId == option['value'];
                  return DropdownMenuItem<String>(
                    value: option['value'],
                    child: Row(
                      children: [
                        Text(_getJobEmoji(option['label']!), style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Text(option['label']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Color(0xFF6B73FF) : Color(0xFF2D2D2D))),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final option = step7ViewModel.jobIndustryOptions.firstWhere((opt) => opt['value'] == value, orElse: () => {'value': '', 'label': ''});
                    step7ViewModel.setJobIndustry(value, option['label']!);
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

class EducationLevelSelector extends StatelessWidget {
  final Step7ViewModel step7ViewModel;
  final Function(bool)? onToggleExpanded;

  const EducationLevelSelector({
    super.key,
    required this.step7ViewModel,
    this.onToggleExpanded,
  });

  String _getEducationEmoji(String label) {
    switch (label.toLowerCase()) {
      case 'high school': return '🏫';
      case 'bachelor\'s degree': return '🎓';
      case 'master\'s degree': return '📜';
      case 'doctorate/phd': return '👨‍🎓';
      case 'trade school': return '🔧';
      case 'associate degree': return '📘';
      case 'prefer not to say': return '❔';
      default: return '🎓';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel = step7ViewModel.educationLevelOptions.firstWhere(
      (option) => option['value'] == step7ViewModel.educationLevelId,
      orElse: () => {'value': '', 'label': ''},
    )['label'] ?? '';
    final emoji = selectedLabel.isNotEmpty ? _getEducationEmoji(selectedLabel) : '🎓';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Text('Education Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: false,
                itemHeight: 48,
                value: step7ViewModel.educationLevelId?.isNotEmpty == true ? step7ViewModel.educationLevelId : null,
                isExpanded: true,
                hint: const Text('Select education level', style: TextStyle(fontSize: 15, color: Color(0xFF757575), fontWeight: FontWeight.w500)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B73FF), size: 26),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
                style: const TextStyle(fontSize: 16, color: Color(0xFF2D2D2D), fontWeight: FontWeight.w600),
                items: step7ViewModel.educationLevelOptions.map((option) {
                  final isSelected = step7ViewModel.educationLevelId == option['value'];
                  return DropdownMenuItem<String>(
                    value: option['value'],
                    child: Row(
                      children: [
                        Text(_getEducationEmoji(option['label']!), style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Text(option['label']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Color(0xFF6B73FF) : Color(0xFF2D2D2D))),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final option = step7ViewModel.educationLevelOptions.firstWhere((opt) => opt['value'] == value, orElse: () => {'value': '', 'label': ''});
                    step7ViewModel.setEducationLevel(value, option['label']!);
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

class DropoutSwitch extends StatelessWidget {
  final Step7ViewModel step7ViewModel;

  const DropoutSwitch({super.key, required this.step7ViewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (step7ViewModel.dropOut ?? false)
                ? const Color(0xFFFF9800)
                : const Color(0xFFE0E0E0),
            width: (step7ViewModel.dropOut ?? false) ? 2 : 1.5,
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
            const Text('❌', style: TextStyle(fontSize: 22)),
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
              activeTrackColor: const Color(0xFFFF9800).withAlpha(80),
              inactiveThumbColor: const Color(0xFFE0E0E0),
              inactiveTrackColor: const Color(0xFFE0E0E0).withAlpha(80),
            ),
          ],
        ),
      ),
    );
  }
} 