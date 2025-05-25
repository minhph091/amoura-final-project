// lib/presentation/discovery/widgets/match_dialog.dart
// Dialog to show when a match occurs.

import 'package:flutter/material.dart';

Future<void> showMatchDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, size: 60, color: Colors.pink),
            const SizedBox(height: 18),
            Text('It\'s a Match!', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircleAvatar(radius: 28, backgroundColor: Colors.blueGrey),
                SizedBox(width: 16),
                CircleAvatar(radius: 28, backgroundColor: Colors.pinkAccent),
              ],
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Start Chatting'),
            ),
          ],
        ),
      ),
    ),
  );
}