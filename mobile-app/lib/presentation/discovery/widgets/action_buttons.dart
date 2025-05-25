// lib/presentation/discovery/widgets/action_buttons.dart
// Animated row of swipe action buttons, positioned at the bottom of Discovery.

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ActionButtonsRow extends StatelessWidget {
  const ActionButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    const undoGradient = LinearGradient(
      colors: [Color(0xFFA8C0FF), Color(0xFF364F6B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    const likeGradient = LinearGradient(
      colors: [Color(0xFFFFA7B5), Color(0xFFFC5185)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    const dislikeGradient = LinearGradient(
      colors: [Color(0xFFFFE0E6), Color(0xFFFC5185)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _AnimatedActionButton(
          icon: FontAwesomeIcons.arrowRotateLeft,
          size: 68,
          iconSize: 30,
          gradient: undoGradient,
          iconColor: Color(0xFF364F6B),
          glowColor: Color(0xFF364F6B),
        ),
        _AnimatedActionButton(
          icon: FontAwesomeIcons.heart,
          size: 82,
          iconSize: 38,
          gradient: likeGradient,
          iconColor: Color(0xFFFC5185),
          glowColor: Color(0xFFFC5185),
          isGlow: true,
        ),
        _AnimatedActionButton(
          icon: FontAwesomeIcons.xmark,
          size: 68,
          iconSize: 32,
          gradient: dislikeGradient,
          iconColor: Color(0xFFFC5185),
          glowColor: Color(0xFFFC5185),
        ),
      ],
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Gradient gradient;
  final Color iconColor;
  final Color glowColor;
  final bool isGlow;

  const _AnimatedActionButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.gradient,
    required this.iconColor,
    required this.glowColor,
    this.isGlow = false,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 170),
      vsync: this,
      lowerBound: 0.93,
      upperBound: 1.12,
      value: 1.0,
    );
  }

  void _onTapDown(_) => _controller.animateTo(0.93, duration: const Duration(milliseconds: 70));
  void _onTapUp(_) => _controller.animateTo(1.12, duration: const Duration(milliseconds: 120)).then((_) {
    _controller.animateTo(1.0, duration: const Duration(milliseconds: 100));
  });
  void _onTapCancel() => _controller.animateTo(1.0, duration: const Duration(milliseconds: 90));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _controller.value,
        child: child,
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            if (widget.isGlow)
              BoxShadow(
                color: widget.glowColor.withValues(alpha: .23),
                blurRadius: 33,
                spreadRadius: 2.3,
                offset: const Offset(0, 9),
              ),
            BoxShadow(
              color: widget.glowColor.withValues(alpha: .09),
              blurRadius: 13,
              spreadRadius: 0.9,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          shape: const CircleBorder(),
          elevation: 0,
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.gradient,
              boxShadow: [],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.size / 2),
              splashColor: widget.iconColor.withValues(alpha: .18),
              highlightColor: widget.iconColor.withValues(alpha: .08),
              onTap: () {},
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Center(
                  child: Icon(widget.icon, color: widget.iconColor, size: widget.iconSize),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}