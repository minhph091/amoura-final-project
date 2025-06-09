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
        final isOptionSelected = value == option['value'];
        // Tùy chỉnh giao diện của mỗi mục trong dropdown
        return DropdownMenuItem<String>(
          value: option['value'],
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: isOptionSelected
                  ? const Color(0xFFD81B60).withAlpha(25)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isOptionSelected
                    ? const Color(0xFFD81B60)
                    : const Color(0xFFBA68C8),
                width: isOptionSelected ? 2 : 1.5,
              ),
              boxShadow: [
                if (isOptionSelected)
                  BoxShadow(
                    color: const Color(0xFFD81B60).withAlpha(40),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Row(
              children: [
                // Icon tròn với biểu tượng orientation
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD81B60),
                  ),
                  child: Center(
                    child: Text(
                      _getIconForOption(option['label']!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option['label']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF424242),
                      fontWeight: FontWeight.bold,
                    ),
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
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.category,
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

  // Hàm để lấy biểu tượng cho từng orientation
  String _getIconForOption(String label) {
    switch (label.toLowerCase()) {
      case 'bisexual':
        return '⚥';
      case 'homosexual':
        return '⚣';
      case 'straight':
        return '⚤';
      default:
        return '⚪';
    }
  }
}