import 'package:flutter/material.dart';

class ReportReasonDropdown extends StatelessWidget {
  final String? selectedReason;
  final Function(String?) onChanged;
  final List<String> reportReasons;

  const ReportReasonDropdown({
    Key? key,
    required this.selectedReason,
    required this.onChanged,
    required this.reportReasons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: selectedReason,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Select a reason',
        ),
        items: reportReasons.map((reason) {
          return DropdownMenuItem<String>(
            value: reason,
            child: Text(reason),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a reason';
          }
          return null;
        },
        isExpanded: true,
      ),
    );
  }
}
