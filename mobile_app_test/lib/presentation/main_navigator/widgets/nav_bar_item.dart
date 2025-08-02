import 'package:flutter/material.dart';
import 'nav_bar_icon.dart';
import 'nav_bar_circle_burst.dart';
import 'floating_ripple_effect.dart';
import 'particle_system.dart';

class NavBarItem extends StatefulWidget {
  final IconData? icon;
  final String? customIconPath;
  final String? label;
  final bool isActive;
  final VoidCallback onTap;
  final int? badgeCount;
  final String? badge;
  final Color activeColor;

  const NavBarItem({
    super.key,
    this.icon,
    this.customIconPath,
    this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount,
    this.badge,
    required this.activeColor,
  });

  @override
  State<NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<NavBarItem> with TickerProviderStateMixin {
  late AnimationController _burstController;
  late AnimationController _mainController;
  late Animation<double> _iconSizeAnim;
  late Animation<double> _backgroundOpacityAnim;
  bool _showBackground = false;

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 430),
    );
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: widget.isActive ? 1 : 0,
    );
    _iconSizeAnim = Tween<double>(begin: 22, end: 26).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutBack),
    );

    // Animation for background opacity effect
    _backgroundOpacityAnim = Tween<double>(begin: 0.25, end: 0.0).animate(
      CurvedAnimation(parent: _burstController, curve: Curves.easeOutCubic),
    );

    // Listen to animation completion to hide background
    _burstController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showBackground = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _mainController.forward();
      } else {
        _mainController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _burstController.dispose();
    _mainController.dispose();
    super.dispose();
  }

  Widget _buildBadge() {
    if (widget.badgeCount != null && widget.badgeCount! > 0) {
      return Positioned(
        right: 0,
        top: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.badgeCount! > 9 ? '9+' : '${widget.badgeCount}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else if (widget.badge != null) {
      return Positioned(
        right: 0,
        top: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.badge!,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // Hiệu ứng nền khi chạm vào item
  Widget _buildBackgroundEffect() {
    return AnimatedBuilder(
      animation: _burstController,
      builder: (context, child) {
        if (!_showBackground) {
          return const SizedBox.shrink();
        }

        final opacity = _backgroundOpacityAnim.value;
        if (opacity <= 0) {
          return const SizedBox.shrink();
        }

        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.activeColor.withValues(alpha: opacity * 0.8),
                widget.activeColor.withValues(alpha: opacity * 0.4),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.activeColor.withValues(alpha: opacity * 0.5),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        );
      },
    );
  }

  void _doBurst() {
    setState(() {
      _showBackground = true;
    });
    _burstController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingRippleEffect(
      rippleColor: widget.activeColor,
      isActive: widget.isActive,
      onTap: () {
        if (!widget.isActive) {
          _doBurst();
          widget.onTap();
        }
      },
      child: SizedBox(
        width: double.infinity, // Sử dụng toàn bộ không gian được cấp
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hiệu ứng nền khi chạm vào
            Positioned.fill(child: _buildBackgroundEffect()),

            // Particle system for active items
            if (widget.isActive)
              Positioned.fill(
                child: ParticleSystem(
                  isActive: widget.isActive,
                  particleColor: widget.activeColor,
                ),
              ),

            // Hiệu ứng burst khi ấn vào
            NavBarCircleBurst(
              animation: _burstController,
              color: widget.activeColor,
              maxRadius: 56,
            ),

            // Icon + badge
            AnimatedBuilder(
              animation: Listenable.merge([_mainController, _burstController]),
              builder:
                  (context, child) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          NavBarIcon(
                            icon: widget.icon,
                            customIconPath: widget.customIconPath,
                            isActive: widget.isActive,
                            activeColor: widget.activeColor,
                            size: _iconSizeAnim.value,
                          ),
                          _buildBadge(),
                        ],
                      ),
                      if (widget.label != null) ...[
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: widget.isActive ? 11 : 10,
                            fontWeight:
                                widget.isActive
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                            color:
                                widget.isActive
                                    ? widget.activeColor
                                    : Colors.grey.shade600,
                          ),
                          child: Text(
                            widget.label!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
