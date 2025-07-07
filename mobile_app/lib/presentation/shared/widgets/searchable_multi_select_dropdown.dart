// lib/presentation/shared/widgets/searchable_multi_select_dropdown.dart
// Reusable widget for searchable multi-select dropdown with flag icons.

import 'package:flutter/material.dart';

class SearchableMultiSelectDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> options;
  final List<String> selectedValues;
  final Function(String, bool) onChanged;

  const SearchableMultiSelectDropdown({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
  });

  @override
  State<SearchableMultiSelectDropdown> createState() => _SearchableMultiSelectDropdownState();
}

class _SearchableMultiSelectDropdownState extends State<SearchableMultiSelectDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredOptions = [];
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    _searchController.addListener(_filterOptions);
  }

  void _filterOptions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOptions = widget.options
          .where((option) =>
          (option['label'] as String).toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFBA68C8), width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF5E6FF).withValues(alpha: 0.3),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.language,
                  color: Color(0xFFD81B60),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.selectedValues.isEmpty
                        ? 'Select languages...'
                        : widget.selectedValues
                        .map((value) => widget.options
                        .firstWhere((option) =>
                    option['value'] == value)['label'])
                        .join(', '),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: widget.selectedValues.isEmpty
                          ? const Color(0xFFBA68C8)
                          : const Color(0xFF424242),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: const Color(0xFFD81B60),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFBA68C8), width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF5E6FF),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search languages...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFBA68C8).withValues(alpha: 0.6),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFD81B60),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFBA68C8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        const BorderSide(color: Color(0xFFD81B60), width: 2),
                      ),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF424242),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: _filteredOptions.length,
                    itemBuilder: (context, index) {
                      final option = _filteredOptions[index];
                      final isSelected =
                      widget.selectedValues.contains(option['value']);
                      return Container(
                        color: isSelected
                            ? const Color(0xFFD81B60).withValues(alpha: 0.2)
                            : Colors.transparent,
                        child: ListTile(
                          leading: option['iconUrl'] != null
                              ? Image.network(
                            option['iconUrl'] as String,
                            width: 30,
                            height: 20,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.language,
                              color: Color(0xFFD81B60),
                              size: 20,
                            ),
                          )
                              : null,
                          title: Text(
                            option['label'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF424242),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFFD81B60),
                            size: 20,
                          )
                              : null,
                          onTap: () {
                            widget.onChanged(option['value'] as String, !isSelected);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}