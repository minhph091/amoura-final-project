// lib/presentation/shared/widgets/profile_option_selector.dart
// Reusable widget for selecting profile options (single or multi-select) with animations.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'custom_dropdown.dart';
import 'searchable_multi_select_dropdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileOptionSelector extends StatelessWidget {
  final List<Map<String, dynamic>> options;
  final List<String>? selectedValues;
  final String? selectedValue;
  final Function(String, bool) onChanged;
  final bool isMultiSelect;
  final bool isDropdown;
  final String labelText;
  final TextStyle? labelStyle;
  final bool scrollable;
  final bool isSearchable;

  const ProfileOptionSelector({
    super.key,
    required this.options,
    this.selectedValues,
    this.selectedValue,
    required this.onChanged,
    this.isMultiSelect = false,
    this.isDropdown = false,
    this.labelText = '',
    this.labelStyle,
    this.scrollable = false,
    this.isSearchable = false,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final theme = Theme.of(context);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                labelText,
                style: labelStyle ?? theme.textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFFD81B60),
                ),
              ),
            ),
          isDropdown
              ? CustomDropdown(
                  options: options.map((opt) => {
                    'value': (opt['value'] ?? opt['id'] ?? '').toString(),
                    'label': (opt['label'] ?? opt['name'] ?? 'Unknown').toString(),
                    if (opt['icon'] != null) 'icon': opt['icon'].toString(),
                    if (opt['color'] != null) 'color': opt['color'].toString(),
                  }).toList(),
                  value: selectedValue,
                  onChanged: (val) {
                    if (val != null && val.isNotEmpty) {
                      onChanged(val, true);
                    }
                  },
                )
              : isMultiSelect && isSearchable
                  ? SearchableMultiSelectDropdown(
                      options: options,
                      selectedValues: selectedValues ?? [],
                      onChanged: onChanged,
                    )
                  : scrollable
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _buildChips(context),
                        )
                      : _buildChips(context),
        ],
      );
    } catch (e, stack) {
      print('ERROR in ProfileOptionSelector: $e\n$stack');
      return Center(child: Text('Widget error: $e'));
    }
  }

  Widget _buildChips(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 48.0; // 24px on each side
    final chipWidth = (screenWidth - horizontalPadding - 8) / 2; // Width for exactly 2 items per row

    return Wrap(
      spacing: 8,
      runSpacing: 12,
      children: options.map((option) {
        final value = option['value'] as String? ?? 'Unknown'; // Xử lý null cho value
        final label = option['label'] as String? ?? 'Unknown'; // Xử lý null cho label
        final isSelected = isMultiSelect
            ? selectedValues?.contains(value) ?? false
            : selectedValue == value;

        return SizedBox(
          width: chipWidth,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onChanged(value, !isSelected),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    if (option.containsKey('icon'))
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: option['icon'] is IconData
                          ? Icon(option['icon'], color: option['color'] as Color? ?? const Color(0xFFD81B60), size: 20)
                          : FaIcon(option['icon'], color: option['color'] as Color? ?? const Color(0xFFD81B60), size: 20),
                      ),
                    Expanded(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? const Color(0xFFD81B60)
                              : const Color(0xFF424242),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Icon(
                          Icons.check_circle,
                          color: Color(0xFFD81B60),
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ).animate().scale(
                duration: const Duration(milliseconds: 200),
                begin: const Offset(1.0, 1.0),
                end: Offset(isSelected ? 1.05 : 1.0, isSelected ? 1.05 : 1.0),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}