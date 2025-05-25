// lib/presentation/main_navigator/widgets/nav_bar_item_3d.dart
// 3D animated bottom navigation bar item with badge support.

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class NavBarItem3D extends StatefulWidget {
  final String iconData;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int? badgeCount;
  final String? badge;

  const NavBarItem3D({
    super.key,
    required this.iconData,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount,
    this.badge,
  });

  @override
  State<NavBarItem3D> createState() => _NavBarItem3DState();
}

class _NavBarItem3DState extends State<NavBarItem3D> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 260), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _elevationAnimation = Tween<double>(begin: 0.0, end: 9.0).animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    if (widget.isActive) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant NavBarItem3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
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
        right: 2, top: 3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.pinkAccent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.3),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
          ),
          child: Text(
            widget.badgeCount! > 9 ? '9+' : '${widget.badgeCount}',
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    } else if (widget.badge != null) {
      return Positioned(
        right: 2, top: 3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.amber, Colors.deepOrange]),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: Colors.amberAccent, blurRadius: 2)],
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

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: widget.onTap,
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
                SizedBox(
                  width: widget.isActive ? 45 : 38,
                  height: widget.isActive ? 45 : 38,
                  child: ModelViewer(
                    src: widget.iconData,
                    ar: false,
                    autoPlay: false,
                    cameraControls: false,
                    backgroundColor: Colors.transparent,
                    disableZoom: true,
                    disablePan: true,
                  ),
                ),
                _buildBadge(),
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