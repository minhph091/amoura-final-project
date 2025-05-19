// lib/presentation/shared/widgets/loading_indicator.dart

import 'package:flutter/material.dart';

// Widget loading indicator chung cho toàn app
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: const TextStyle(fontSize: 16)),
          ]
        ],
      ),
    );
  }
}