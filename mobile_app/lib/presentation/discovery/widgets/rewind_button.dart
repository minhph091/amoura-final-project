import 'package:flutter/material.dart';

class RewindButton extends StatelessWidget {
  final VoidCallback onRewind;

  const RewindButton({super.key, required this.onRewind});

  Future<void> _handleRewindTap(BuildContext context) async {
    // Tạm thời cho phép tất cả user dùng rewind, không cần VIP
    onRewind();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _handleRewindTap(context),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.replay,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
