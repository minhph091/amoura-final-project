import 'package:flutter/material.dart';
import '../../../data/models/profile/interest_model.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import 'profile_card.dart';

class SwipeableCard extends StatefulWidget {
  final UserRecommendationModel profile;
  final List<InterestModel> interests;
  final String? distance;
  final UserRecommendationModel? nextProfile;
  final List<InterestModel>? nextInterests;
  final String? nextDistance;
  final VoidCallback? onLike;
  final VoidCallback? onPass;
  final void Function(bool)? onHighlightLike;
  final void Function(bool)? onHighlightPass;

  const SwipeableCard({
    super.key,
    required this.profile,
    required this.interests,
    this.distance,
    this.nextProfile,
    this.nextInterests,
    this.nextDistance,
    this.onLike,
    this.onPass,
    this.onHighlightLike,
    this.onHighlightPass,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  double _offsetX = 0;
  late AnimationController _animController;
  late Animation<double> _anim;
  bool _highlightLike = false;
  bool _highlightPass = false;

  static const double swipeThreshold = 120;
  static const double maxAngle = 18; // degrees

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _anim = Tween<double>(begin: 0, end: 0).animate(_animController)
      ..addListener(() {
        setState(() {
          _offsetX = _anim.value;
        });
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    _highlightLike = false;
    _highlightPass = false;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offsetX += details.delta.dx;
      _highlightLike = _offsetX > 30;
      _highlightPass = _offsetX < -30;
    });
    widget.onHighlightLike?.call(_highlightLike);
    widget.onHighlightPass?.call(_highlightPass);
  }

  void _onDragEnd(DragEndDetails details) {
    widget.onHighlightLike?.call(false);
    widget.onHighlightPass?.call(false);
    if (_offsetX > swipeThreshold) {
      // Like
      _animateOut(1);
      widget.onLike?.call();
    } else if (_offsetX < -swipeThreshold) {
      // Pass
      _animateOut(-1);
      widget.onPass?.call();
    } else {
      // Return to center
      _animateBack();
    }
  }

  void _animateOut(int direction) {
    _anim = Tween<double>(
      begin: _offsetX,
      end: direction * 500,
    ).animate(_animController);
    _animController.forward(from: 0).then((_) {
      setState(() {
        _offsetX = 0;
        _highlightLike = false;
        _highlightPass = false;
      });
    });
  }

  void _animateBack() {
    _anim = Tween<double>(begin: _offsetX, end: 0).animate(_animController);
    _animController.forward(from: 0);
    setState(() {
      _highlightLike = false;
      _highlightPass = false;
    });
    widget.onHighlightLike?.call(false);
    widget.onHighlightPass?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    final angle = (_offsetX / 400) * maxAngle * 3.1416 / 180;
    final nextCardScale =
        0.93 + (0.07 * (_offsetX.abs() / swipeThreshold).clamp(0, 1));
    final nextCardOffset =
        18.0 - 18.0 * (_offsetX.abs() / swipeThreshold).clamp(0, 1);
    return Stack(
      children: [
        if (widget.nextProfile != null && widget.nextInterests != null)
          Transform.scale(
            scale: nextCardScale,
            child: Transform.translate(
              offset: Offset(0, nextCardOffset),
              child: ProfileCard(
                key: ValueKey('next_profile_${widget.nextProfile!.userId}'),
                profile: widget.nextProfile!,
                interests: widget.nextInterests!,
                distance: widget.nextDistance,
              ),
            ),
          ),
        GestureDetector(
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_offsetX, 0),
                child: Transform.rotate(
                  angle: angle,
                  child: Stack(
                    children: [
                      ProfileCard(
                        key: ValueKey(
                          'current_profile_${widget.profile.userId}',
                        ),
                        profile: widget.profile,
                        interests: widget.interests,
                        distance: widget.distance,
                      ),
                      // Like/Pass highlight overlays
                      if (_highlightLike)
                        Positioned(
                          top: 40,
                          right: 30,
                          child: Opacity(
                            opacity: (_offsetX / 120).clamp(0, 1),
                            child: _buildHighlightIcon(
                              Icons.favorite,
                              Colors.pinkAccent,
                            ),
                          ),
                        ),
                      if (_highlightPass)
                        Positioned(
                          top: 40,
                          left: 30,
                          child: Opacity(
                            opacity: (-_offsetX / 120).clamp(0, 1),
                            child: _buildHighlightIcon(
                              Icons.close,
                              Colors.redAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color, width: 2.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 36),
    );
  }
}
