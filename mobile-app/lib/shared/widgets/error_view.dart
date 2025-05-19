// lib/presentation/shared/widgets/error_view.dart

import 'package:flutter/material.dart';

// Widget hiển thị thông báo lỗi chung
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error, color: Colors.red.shade400, size: 48),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(fontSize: 16)),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Retry"),
            ),
          ],
        ],
      ),
    );
  }
}