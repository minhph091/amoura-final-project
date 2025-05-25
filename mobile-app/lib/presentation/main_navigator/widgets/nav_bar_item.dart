// lib/presentation/main_navigator/widgets/nav_bar_item.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:particle_field/particle_field.dart';
import 'gradient_icon.dart';
import '../../../core/constants/asset_path.dart';

class NavBarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int? badgeCount;
  final String? badge;
  final Gradient gradient;

  const NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount,
    this.badge,
    required this.gradient,
  });

  @override
  State<NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<NavBarItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _showSparkle = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 260), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _elevationAnimation = Tween<double>(begin: 0.0, end: 9.0).animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    if (widget.isActive) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
        setState(() => _showSparkle = true);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _showSparkle = false);
        });
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBadge() {
    if (widget.badgeCount != null && widget.badgeCount! > 0) {
      return Positioned(
        right: 2,
        top: 3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.pinkAccent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.3),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
          ),
          child: Text(
            widget.badgeCount! > 9 ? '9+' : '${widget.badgeCount}',
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    } else if (widget.badge != null) {
      return Positioned(
        right: 2,
        top: 3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.amber, Colors.deepOrange]),
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [BoxShadow(color: Colors.amberAccent, blurRadius: 2)],
          ),
          child: Text(
            widget.badge!,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSparkleEffect() {
    if (!_showSparkle) return const SizedBox.shrink();
    return Positioned.fill(
      child: ParticleField(
        spriteSheet: SpriteSheet(
          image: const AssetImage(AssetPath.sparkleEffect),
          frameWidth: 32,
          frameHeight: 32,
        ),
        blendMode: BlendMode.srcIn,
        onTick: (controller, elapsed, size) {
          final r = Random();
          List<Particle> particles = [];
          for (int i = 0; i < 10; i++) {
            particles.add(
              Particle(
                x: size.width / 2 + r.nextDouble() * 20 - 10,
                y: size.height / 2 + r.nextDouble() * 20 - 10,
                vx: r.nextDouble() * 50 - 25,
                vy: r.nextDouble() * 50 - 25,
                lifespan: 0.5,
                frame: r.nextInt(4),
                scale: 0.5 + r.nextDouble() * 0.5,
              ),
            );
          }
          controller.particles = particles;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () {
        widget.onTap();
        setState(() => _showSparkle = true);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _showSparkle = false);
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (ctx, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            elevation: _elevationAnimation.value,
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                GradientIcon(
                  icon: widget.icon,
                  size: widget.isActive ? 30 : 24,
                  gradient: widget.gradient,
                  withShadow: widget.isActive,
                ),
                _buildBadge(),
                _buildSparkleEffect(),
                Positioned(
                  bottom: -17,
                  child: Text(
                    widget.label,
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: widget.isActive ? activeColor : Colors.grey.shade500,
                      fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}