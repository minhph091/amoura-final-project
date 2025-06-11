// lib/presentation/shared/widgets/custom_dropdown.dart
// Reusable dropdown widget for single-select options.

import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final List<Map<String, String>> options;
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
      isExpanded: true, // This fixes the overflow issue
      menuMaxHeight: 300, // Limit dropdown height for long lists
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
        // Add proper padding to ensure text fits
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
        final isOptionSelected = value == option['value'];
        return DropdownMenuItem<String>(
          value: option['value'],
          child: Row(
            children: [
              if (option.containsKey('icon'))
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    IconData(int.parse(option['icon']!), fontFamily: 'MaterialIcons'),
                    color: isOptionSelected
                        ? const Color(0xFFD81B60)
                        : (option['color'] != null ? Color(int.parse(option['color']!)) : const Color(0xFF424242)),
                    size: 20,
                  ),
                ),
              Expanded(
                child: Text(
                  option['label']!,
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
        return options.map<Widget>((Map<String, String> option) {
          return Container(
            alignment: Alignment.centerLeft,
            constraints: const BoxConstraints(minWidth: 100),
            child: Row(
              children: [
                if (option.containsKey('icon'))
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      IconData(int.parse(option['icon']!), fontFamily: 'MaterialIcons'),
                      color: const Color(0xFFD81B60),
                      size: 20,
                    ),
                  ),
                Expanded(
                  child: Text(
                    option['label']!,
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
}