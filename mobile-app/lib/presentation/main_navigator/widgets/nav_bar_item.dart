import 'package:flutter/material.dart';
import 'nav_bar_icon.dart';
import 'nav_bar_circle_burst.dart';
import 'nav_bar_sparkle_effect.dart';

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
  late Animation<double> _scaleAnim;
  late Animation<double> _iconSizeAnim;
  bool _showSparkle = false;

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
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );
    _iconSizeAnim = Tween<double>(begin: 24, end: 30).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );
    if (widget.isActive) _showSparkle = false;
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

  void _doBurst() async {
    _burstController.forward(from: 0);

    // Bật hiệu ứng sparkle khi ấn vào và tắt sau 1s
    setState(() => _showSparkle = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showSparkle = false);
    });

    if (!widget.isActive) {
      await Future.delayed(const Duration(milliseconds: 100));
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _doBurst,
        child: SizedBox(
          width: 68,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Hiệu ứng burst khi ấn vào
              NavBarCircleBurst(
                animation: _burstController,
                color: widget.activeColor,
                maxRadius: 56,
              ),
              // Sparkle hiệu ứng khi ấn vào icon (icon center, nhỏ vừa, rơi xuống)
              Positioned(
                bottom: 8,
                child: NavBarSparkleEffect(
                  show: _showSparkle,
                  size: 32,
                ),
              ),
              // Border luôn hiện nếu đang active
              AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Opacity(
                    opacity: widget.isActive ? 1 : 0,
                    child: Container(
                      width: 44 * _scaleAnim.value,
                      height: 44 * _scaleAnim.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.activeColor,
                          width: 2.2,
                        ),
                      ),
                    ),
                  );
                },
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
      ),
    );
  }
}