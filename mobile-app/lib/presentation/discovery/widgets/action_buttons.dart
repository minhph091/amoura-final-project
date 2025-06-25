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
  const ActionButtonsRow(
      {super.key, this.highlightLike = false, this.highlightPass = false});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DiscoveryViewModel>(context);
    final subscriptionService = Provider.of<SubscriptionService>(context);

    const lightGradient = LinearGradient(
      colors: [Colors.white, Color(0xFFF5F6FA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
    // Define new vibrant colors & gradients
    const likeColor = Color(0xFFE91E63);
    const passColor = Color(0xFFD32F2F);
    const rewindColor = Color(0xFF757575);

    const likeHighlightGradient = LinearGradient(
      colors: [Color(0xFFF857A6), Color(0xFFFF5858)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    const passHighlightGradient = LinearGradient(
      colors: [Color(0xFFF44336), Color(0xFFB71C1C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );


    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 90),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _AnimatedActionButton(
            icon: FontAwesomeIcons.arrowRotateLeft,
            size: 68,
            iconSize: 22,
            gradient: lightGradient,
            iconColor: rewindColor,
            glowColor: rewindColor,
            isDimmed: highlightLike || highlightPass,
            onTap: () {
              if (subscriptionService.isVip) {
                vm.rewindLastProfile();
              } else {
                VipUpgradeDialog.show(
                  context: context,
                  feature: 'Quay lại người đã bỏ qua',
                  description:
                      'Đã bỏ lỡ một người có vẻ phù hợp với bạn? Nâng cấp lên Amoura VIP để quay lại người vừa vuốt trái và nhiều tính năng độc quyền khác.',
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
            iconColor: likeColor,
            glowColor: likeColor,
            isGlow: true,
            isBreathing: true,
            isHighlighted: highlightLike,
            isDimmed: highlightPass,
            highlightedGradient: likeHighlightGradient,
            onTap: () async {
              await vm.likeCurrentProfile();
            },
          ),
          _AnimatedActionButton(
            icon: FontAwesomeIcons.xmark,
            size: 68,
            iconSize: 24,
            gradient: lightGradient,
            iconColor: passColor,
            glowColor: passColor,
            isHighlighted: highlightPass,
            isDimmed: highlightLike,
            highlightedGradient: passHighlightGradient,
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
  final bool isDimmed;
  final Gradient? highlightedGradient;
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
    this.isDimmed = false,
    this.highlightedGradient,
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

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 170),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 0.5,
    );

    _breathController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    if (widget.isBreathing) {
      _breathController.repeat(reverse: true);
    }

    _tapScaleAnimation = Tween<double>(begin: 0.93, end: 1.12).animate(
      CurvedAnimation(
        parent: _tapController,
        curve: Curves.easeInOut,
      ),
    );

    _breathScaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (!widget.isBreathing) {
      _tapController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 70),
      );
    }
  }

  void _onTapUp(_) {
    if (!widget.isBreathing) {
      _tapController
          .animateTo(
        1.0,
        duration: const Duration(milliseconds: 120),
      )
          .then((_) {
        _tapController.animateTo(
          0.5,
          duration: const Duration(milliseconds: 100),
        );
      });
    }
  }

  void _onTapCancel() {
    if (!widget.isBreathing) {
      _tapController.animateTo(
        0.5,
        duration: const Duration(milliseconds: 90),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double targetScale = 1.0;
    if (widget.isHighlighted) {
      targetScale = 1.25;
    } else if (widget.isDimmed) {
      targetScale = 0.8;
    }
    
    final double targetOpacity = widget.isDimmed ? 0.0 : 1.0;
    
    final Gradient backgroundGradient;
    final Color iconColor;
    final List<BoxShadow> boxShadow;

    if (widget.isHighlighted) {
      backgroundGradient = widget.highlightedGradient ??
          LinearGradient(colors: [widget.iconColor, widget.iconColor]);
      iconColor = Colors.white;
      boxShadow = [
        BoxShadow(
          color: widget.iconColor.withOpacity(0.7),
          blurRadius: 30,
          spreadRadius: 5,
        ),
      ];
    } else {
      backgroundGradient = widget.gradient;
      iconColor = widget.iconColor;
      boxShadow = [
        if (widget.isGlow)
          BoxShadow(
            color: widget.glowColor.withOpacity(0.23),
            blurRadius: 33,
            spreadRadius: 2.3,
            offset: const Offset(0, 9),
          ),
        BoxShadow(
          color: widget.glowColor.withOpacity(0.09),
          blurRadius: 13,
          spreadRadius: 0.9,
          offset: const Offset(0, 5),
        ),
      ];
    }

    return AnimatedScale(
      scale: targetScale,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: targetOpacity,
        duration: const Duration(milliseconds: 200),
        child: AnimatedBuilder(
          animation: Listenable.merge([_tapController, _breathController]),
          builder: (context, child) {
            final tapScale = _tapScaleAnimation.value;
            final breathScale =
                widget.isBreathing ? _breathScaleAnimation.value : 1.0;
            final combinedScale = tapScale * breathScale;
            
            return Transform.scale(
              scale: combinedScale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: backgroundGradient,
                  boxShadow: boxShadow,
                ),
                child: Material(
                  shape: const CircleBorder(),
                  elevation: 0,
                  color: Colors.transparent,
                  child: Ink(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(widget.size / 2),
                      splashColor: iconColor.withOpacity(0.3),
                      highlightColor: iconColor.withOpacity(0.15),
                      onTap:
                          widget.isDimmed ? null : widget.onTap,
                      onTapDown: _onTapDown,
                      onTapUp: _onTapUp,
                      onTapCancel: _onTapCancel,
                      child: Center(
                        child: FaIcon(
                          widget.icon,
                          size: widget.iconSize,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}