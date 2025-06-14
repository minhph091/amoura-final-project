import 'package:flutter/material.dart';
import 'nav_bar_icon.dart';
import 'nav_bar_circle_burst.dart';

class NavBarItem extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final int? badgeCount;
  final String? badge;
  final Color activeColor;

  const NavBarItem({
    super.key,
    required this.icon,
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
    _iconSizeAnim = Tween<double>(begin: 24, end: 30).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
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
        right: -5,
        top: -5,
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
        right: -8,
        top: -5,
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
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20), right: Radius.circular(20)),
            color: widget.activeColor.withOpacity(opacity),
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
    return GestureDetector(
      onTap: () {
        if (!widget.isActive) {
          _doBurst();
          widget.onTap();
        }
      },
      behavior: HitTestBehavior.opaque, // Để đảm bảo vùng chạm bao phủ toàn bộ khu vực
      child: SizedBox(
        width: double.infinity, // Sử dụng toàn bộ không gian được cấp
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hiệu ứng nền khi chạm vào
            Positioned.fill(
              child: _buildBackgroundEffect(),
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
              builder: (context, child) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      NavBarIcon(
                        icon: widget.icon,
                        isActive: widget.isActive,
                        activeColor: widget.activeColor,
                        size: _iconSizeAnim.value,
                      ),
                      _buildBadge(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

