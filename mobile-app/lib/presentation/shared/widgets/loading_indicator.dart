// lib/presentation/shared/widgets/loading_indicator.dart

import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (Rect bounds) {
                  return SweepGradient(
                    colors: [
                      Colors.pinkAccent,
                      Colors.orangeAccent,
                      Colors.pinkAccent,
                    ],
                    stops: const [0.0, 0.7, 1.0],
                    startAngle: 0.0,
                    endAngle: 3.14 * 2,
                    transform: GradientRotation(_controller.value * 6.28),
                  ).createShader(bounds);
                },
                child: child,
              );
            },
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 4,
            ),
          ),
          if (widget.message != null && widget.message!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ]
        ],
      ),
    );
  }
}