// filepath: c:\amoura-final-project\mobile-app\lib\presentation\subscription\widgets\vip_benefit_item.dart
import 'package:flutter/material.dart';

class VIPBenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const VIPBenefitItem({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
          size: 22,
        ),
      ],
    );
  }
}
