// lib/presentation/discovery/widgets/action_buttons_simple.dart
import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass button
          FloatingActionButton(
            heroTag: "pass_button",
            onPressed: () {
              // TODO: Implement pass logic
            },
            backgroundColor: Colors.grey[300],
            child: const Icon(
              Icons.close,
              color: Colors.red,
              size: 30,
            ),
          ),
          
          // Like button  
          FloatingActionButton(
            heroTag: "like_button",
            onPressed: () {
              // TODO: Implement like logic
            },
            backgroundColor: Colors.pink[100],
            child: const Icon(
              Icons.favorite,
              color: Colors.pink,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
