// lib/presentation/profile/edit/widgets/edit_profile_accordion_section.dart

import 'package:flutter/material.dart';
import 'edit_profile_accordion_controller.dart';

class EditProfileAccordionSection extends StatelessWidget {
  final EditProfileAccordionController controller;
  final String sectionKey;
  final String title;
  final IconData icon;
  final Widget child;

  const EditProfileAccordionSection({
    super.key,
    required this.controller,
    required this.sectionKey,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = controller.currentOpenKey == sectionKey;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (isExpanded)
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              child: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
            ),
            onTap: () => controller.toggle(sectionKey),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: child,
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}