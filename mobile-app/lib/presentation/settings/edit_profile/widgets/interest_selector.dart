import 'package:flutter/material.dart';

class InterestSelector extends StatelessWidget {
  const InterestSelector({super.key});
  @override
  Widget build(BuildContext context) {
    // UI for displaying selectable chips for each user interest.
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // for (final interest in interests) ...[
            //   ChoiceChip(
            //     label: Text(interest.label),
            //     selected: selectedInterests.contains(interest),
            //     onSelected: (selected) => ...
            //   ),
            // ]
          ],
        ),
      ),
    );
  }
}