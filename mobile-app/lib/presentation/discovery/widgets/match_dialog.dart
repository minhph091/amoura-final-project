// lib/presentation/discovery/widgets/match_dialog.dart
// Dialog to show when a match occurs.

import 'package:flutter/material.dart';
import '../../../data/models/match/swipe_response_model.dart';

Future<void> showMatchDialog(BuildContext context, SwipeResponseModel matchResponse) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, size: 60, color: Colors.pink),
            const SizedBox(height: 18),
            Text(
              'It\'s a Match!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 12),
            if (matchResponse.matchMessage != null)
              Text(
                matchResponse.matchMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.favorite, color: Colors.pink, size: 24),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.pinkAccent,
                  child: Text(
                    matchResponse.matchedUsername?.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text('Keep Swiping'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to chat screen
                      // Navigator.pushNamed(context, '/chat', arguments: matchResponse.matchId ?? 0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Start Chatting'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}