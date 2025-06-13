// lib/presentation/shared/widgets/custom_dropdown.dart
// Reusable dropdown widget for single-select options.

import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> options;
  final String? value;
  final Function(String?) onChanged;

  const CustomDropdown({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValueSelected = value != null && value!.isNotEmpty;

    return DropdownButtonFormField<String>(
      isExpanded: true,
      menuMaxHeight: 300,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.category,
          color: isValueSelected ? const Color(0xFFD81B60) : const Color(0xFFBA68C8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBA68C8), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD81B60), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isValueSelected ? const Color(0xFFD81B60) : const Color(0xFFBA68C8),
            width: isValueSelected ? 2.0 : 1.5,
          ),
        ),
        filled: true,
        fillColor: isValueSelected
            ? const Color(0xFFD81B60).withAlpha(25)
            : Colors.white.withAlpha(240),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      value: value,
      hint: Text(
        'Select an option...',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: const Color(0xFFBA68C8),
        ),
      ),
      dropdownColor: Colors.white,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD81B60)),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF424242),
        fontWeight: FontWeight.bold,
      ),
      items: options.map((option) {
        final isOptionSelected = value == option['value']?.toString();
        return DropdownMenuItem<String>(
          value: option['value']?.toString(),
          child: Row(
            children: [
              if (option.containsKey('icon'))
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildIcon(option['icon'], isOptionSelected, option['color']),
                ),
              Expanded(
                child: Text(
                  option['label']?.toString() ?? 'Unknown',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isOptionSelected ? const Color(0xFFD81B60) : const Color(0xFF424242),
                    fontWeight: isOptionSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isOptionSelected)
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
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          onChanged(val);
        }
      },
      selectedItemBuilder: (BuildContext context) {
        return options.map<Widget>((Map<String, dynamic> option) {
          return Container(
            alignment: Alignment.centerLeft,
            constraints: const BoxConstraints(minWidth: 100),
            child: Row(
              children: [
                if (option.containsKey('icon'))
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildIcon(option['icon'], true, option['color']),
                  ),
                Expanded(
                  child: Text(
                    option['label']?.toString() ?? 'Unknown',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF424242),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildIcon(dynamic icon, bool isSelected, dynamic color) {
    if (icon is IconData) {
      return Icon(
        icon,
        color: isSelected
            ? const Color(0xFFD81B60)
            : (color != null ? _parseColor(color) : const Color(0xFF424242)),
        size: 20,
      );
    } else if (icon is String) {
      try {
        return Icon(
          IconData(int.parse(icon), fontFamily: 'MaterialIcons'),
          color: isSelected
              ? const Color(0xFFD81B60)
              : (color != null ? _parseColor(color) : const Color(0xFF424242)),
          size: 20,
        );
      } catch (e) {
        return const Icon(Icons.error, color: Colors.red, size: 20);
      }
    }
    return const Icon(Icons.error, color: Colors.red, size: 20);
  }

  Color _parseColor(dynamic color) {
    if (color is Color) return color;
    if (color is String) {
      try {
        return Color(int.parse(color));
      } catch (e) {
        return const Color(0xFF424242);
      }
    }
    return const Color(0xFF424242);
  }
}