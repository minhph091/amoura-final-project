import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class FloatingRippleEffect extends StatefulWidget {
  final Widget child;
  final Color rippleColor;
  final VoidCallback onTap;
  final bool isActive;

  const FloatingRippleEffect({
    super.key,
    required this.child,
    required this.rippleColor,
    required this.onTap,
    required this.isActive,
  });

  @override
  State<FloatingRippleEffect> createState() => _FloatingRippleEffectState();
}

class _FloatingRippleEffectState extends State<FloatingRippleEffect>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _floatController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOutCirc),
    );

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.linear));

    if (widget.isActive) {
      _floatController.repeat();
    }
  }

  @override
  void didUpdateWidget(FloatingRippleEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _floatController.repeat();
      } else {
        _floatController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Thêm haptic feedback
    HapticFeedback.lightImpact();

    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rippleAnimation, _floatAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset:
                widget.isActive
                    ? Offset(0, math.sin(_floatAnimation.value) * 2)
                    : Offset.zero,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effect
                if (_rippleAnimation.value > 0)
                  Container(
                    width: 60 * _rippleAnimation.value,
                    height: 60 * _rippleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.rippleColor.withValues(
                          alpha: (1 - _rippleAnimation.value) * 0.5,
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                // Active floating circles
                if (widget.isActive) ...[
                  for (int i = 0; i < 3; i++)
                    Transform.rotate(
                      angle: _floatAnimation.value + (i * 2 * math.pi / 3),
                      child: Transform.translate(
                        offset: const Offset(25, 0),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.rippleColor.withValues(alpha: 0.6),
                            boxShadow: [
                              BoxShadow(
                                color: widget.rippleColor.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
                widget.child,
              ],
            ),
          );
        },
      ),
    );
  }
}
