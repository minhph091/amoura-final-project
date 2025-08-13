// lib/presentation/shared/widgets/shake_widget.dart
// Widget to apply shake animation when validation fails.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;

  const ShakeWidget({
    super.key,
    required this.child,
    this.shake = false,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.shake
        ? widget.child.animate().shake(
      duration: const Duration(milliseconds: 400),
      hz: 4,
      offset: const Offset(2, 0),
    )
        : widget.child;
  }
}
