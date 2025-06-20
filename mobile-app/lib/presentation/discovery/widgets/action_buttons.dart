// lib/presentation/discovery/widgets/action_buttons.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../subscription/widgets/vip_upgrade_dialog.dart';
import '../discovery_viewmodel.dart';
import '../../../infrastructure/services/subscription_service.dart';

class ActionButtonsRow extends StatelessWidget {
  final bool highlightLike;
  final bool highlightPass;
  const ActionButtonsRow({super.key, this.highlightLike = false, this.highlightPass = false});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DiscoveryViewModel>(context);
    final subscriptionService = Provider.of<SubscriptionService>(context);

    const lightGradient = LinearGradient(
      colors: [Colors.white, Color(0xFFF5F6FA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 82),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _AnimatedActionButton(
            icon: FontAwesomeIcons.arrowRotateLeft,
            size: 68,
            iconSize: 22,
            gradient: lightGradient,
            iconColor: const Color(0xFF364F6B),
            glowColor: const Color(0xFF364F6B),
            onTap: () {
              if (subscriptionService.isVip) {
                vm.rewindLastProfile();
              } else {
                VipUpgradeDialog.show(
                  context: context,
                  feature: 'Quay lại người đã bỏ qua',
                  description: 'Đã bỏ lỡ một người có vẻ phù hợp với bạn? Nâng cấp lên Amoura VIP để quay lại người vừa vuốt trái và nhiều tính năng độc quyền khác.',
                  icon: Icons.replay,
                );
              }
            },
          ),
          _AnimatedActionButton(
            icon: FontAwesomeIcons.heart,
            size: 82,
            iconSize: 26,
            gradient: lightGradient,
            iconColor: const Color(0xFFFC5185),
            glowColor: const Color(0xFFFC5185),
            isGlow: true,
            isBreathing: true,
            isHighlighted: highlightLike,
            onTap: () async {
              await vm.likeCurrentProfile();
            },
          ),
          _AnimatedActionButton(
            icon: FontAwesomeIcons.xmark,
            size: 68,
            iconSize: 24,
            gradient: lightGradient,
            iconColor: const Color(0xFFFC5185),
            glowColor: const Color(0xFFFC5185),
            isHighlighted: highlightPass,
            onTap: () async {
              await vm.dislikeCurrentProfile();
            },
          ),
        ],
      ),
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
  final bool isBreathing;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _AnimatedActionButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.gradient,
    required this.iconColor,
    required this.glowColor,
    this.isGlow = false,
    this.isBreathing = false,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _breathController;
  late Animation<double> _tapScaleAnimation;
  late Animation<double> _breathScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Controller cho hiệu ứng nhấn, giá trị nằm trong [0, 1]
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 170),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 0.5, // Giá trị ban đầu tương ứng với scale 1.0
    );

    // Controller cho hiệu ứng thở (chỉ cho icon trái tim)
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    if (widget.isBreathing) {
      _breathController.repeat(reverse: true);
    }

    // Animation cho hiệu ứng nhấn, ánh xạ từ [0, 1] sang [0.93, 1.12]
    _tapScaleAnimation = Tween<double>(begin: 0.93, end: 1.12).animate(
      CurvedAnimation(
        parent: _tapController,
        curve: Curves.easeInOut,
      ),
    );

    // Animation cho hiệu ứng thở
    _breathScaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onTapDown(_) {
    if (!widget.isBreathing) {
      _tapController.animateTo(
        0.0, // Tương ứng với scale 0.93
        duration: const Duration(milliseconds: 70),
      );
    }
  }

  void _onTapUp(_) {
    if (!widget.isBreathing) {
      _tapController
          .animateTo(
        1.0, // Tương ứng với scale 1.12
        duration: const Duration(milliseconds: 120),
      )
          .then((_) {
        _tapController.animateTo(
          0.5, // Trở về scale 1.0
          duration: const Duration(milliseconds: 100),
        );
      });
    }
  }

  void _onTapCancel() {
    if (!widget.isBreathing) {
      _tapController.animateTo(
        0.5, // Trở về scale 1.0
        duration: const Duration(milliseconds: 90),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_tapController, _breathController]),
      builder: (context, child) {
        final tapScale = _tapScaleAnimation.value;
        final breathScale = widget.isBreathing ? _breathScaleAnimation.value : 1.0;
        final combinedScale = tapScale * breathScale;
        final highlightShadow = widget.isHighlighted
            ? [
                BoxShadow(
                  color: widget.iconColor.withOpacity(0.45),
                  blurRadius: 36,
                  spreadRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ]
            : [];
        return Transform.scale(
          scale: combinedScale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                if (widget.isGlow)
                  BoxShadow(
                    color: widget.glowColor.withValues(alpha: 0.23),
                    blurRadius: 33,
                    spreadRadius: 2.3,
                    offset: const Offset(0, 9),
                  ),
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: 0.09),
                  blurRadius: 13,
                  spreadRadius: 0.9,
                  offset: const Offset(0, 5),
                ),
                ...highlightShadow,
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
                  boxShadow: const [],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(widget.size / 2),
                  splashColor: widget.iconColor.withValues(alpha: 0.18),
                  highlightColor: widget.iconColor.withValues(alpha: 0.08),
                  onTap: widget.onTap,
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTapCancel: _onTapCancel,
                  child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: Center(
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: widget.iconSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            if (widget.isGlow)
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.23),
                blurRadius: 33,
                spreadRadius: 2.3,
                offset: const Offset(0, 9),
              ),
            BoxShadow(
              color: widget.glowColor.withValues(alpha: 0.09),
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
              boxShadow: const [],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.size / 2),
              splashColor: widget.iconColor.withValues(alpha: 0.18),
              highlightColor: widget.iconColor.withValues(alpha: 0.08),
              onTap: widget.onTap,
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Center(
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: widget.iconSize,
                  ),
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
    _tapController.dispose();
    _breathController.dispose();
    super.dispose();
  }
}