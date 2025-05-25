// lib/presentation/discovery/widgets/filter_dialog.dart
// Modal dialog for filters (age, distance, etc.)

import 'package:flutter/material.dart';

Future<void> showFilterDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white.withValues(alpha: 0.8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFFF5F6FA), Color(0xFFEFF3FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 26),
            Placeholder(fallbackHeight: 72),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    ),
  );
}