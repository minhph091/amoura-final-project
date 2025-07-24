import 'package:flutter/material.dart';

class GlowEffect extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final bool isActive;
  final double glowRadius;

  const GlowEffect({
    super.key,
    required this.child,
    required this.glowColor,
    required this.isActive,
    this.glowRadius = 20,
  });

  @override
  State<GlowEffect> createState() => _GlowEffectState();
}

class _GlowEffectState extends State<GlowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlowEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(
                  alpha: 0.6 * _glowAnimation.value,
                ),
                blurRadius: widget.glowRadius * _glowAnimation.value,
                spreadRadius: 2 * _glowAnimation.value,
              ),
              BoxShadow(
                color: widget.glowColor.withValues(
                  alpha: 0.3 * _glowAnimation.value,
                ),
                blurRadius: widget.glowRadius * 1.5 * _glowAnimation.value,
                spreadRadius: 4 * _glowAnimation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
