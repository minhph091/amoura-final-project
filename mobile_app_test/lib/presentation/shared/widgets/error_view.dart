// lib/presentation/shared/widgets/error_view.dart

import 'package:flutter/material.dart';
import '../../../config/language/app_localizations.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_rounded, color: Colors.red.shade400, size: 48),
              const SizedBox(height: 14),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRetry,
                  label: Text(localizations.translate('retry')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
