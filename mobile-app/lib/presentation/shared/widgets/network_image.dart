// lib/presentation/shared/widgets/network_image.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A widget that displays a network image with error handling and loading state.
class NetworkImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;
  final Widget? errorWidget;
  final Widget? placeholder;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width = 120,
    this.height = 120,
    this.borderRadius = 16,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildError(context, 'No image');
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              Shimmer.fromColors(
                baseColor: theme.colorScheme.surfaceContainerHighest,
                highlightColor: theme.colorScheme.surface,
                child: Container(
                  width: width,
                  height: height,
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) =>
        errorWidget ?? _buildError(context, 'Failed to load'),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 36),
            const SizedBox(height: 6),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}