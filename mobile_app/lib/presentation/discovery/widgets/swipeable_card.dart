import 'package:flutter/material.dart';
import '../../../data/models/profile/interest_model.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import 'profile_card.dart';

class SwipeableCardStack extends StatefulWidget {
  final UserRecommendationModel currentProfile;
  final List<InterestModel> currentInterests;
  final String? currentDistance;
  final UserRecommendationModel? nextProfile;
  final List<InterestModel>? nextInterests;
  final String? nextDistance;
  final void Function(bool)? onHighlightLike;
  final void Function(bool)? onHighlightPass;
  final VoidCallback? onSwiped;

  const SwipeableCardStack({
    super.key,
    required this.currentProfile,
    required this.currentInterests,
    this.currentDistance,
    this.nextProfile,
    this.nextInterests,
    this.nextDistance,
    this.onHighlightLike,
    this.onHighlightPass,
    this.onSwiped,
  });

  @override
  State<SwipeableCardStack> createState() => _SwipeableCardStackState();
}

class _SwipeableCardStackState extends State<SwipeableCardStack> with SingleTickerProviderStateMixin {
  double _offsetX = 0;
  double _offsetY = 0;
  late AnimationController _animController;
  late Animation<double> _anim;
  bool _highlightLike = false;
  bool _highlightPass = false;
  bool _isAnimating = false;

  static const double swipeThreshold = 100;
  static const double maxAngle = 15;
  static const double peekThreshold = 20;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _anim = Tween<double>(begin: 0, end: 0).animate(_animController)
      ..addListener(() {
        setState(() {
          _offsetX = _anim.value;
        });
      });
  }

  @override
  void didUpdateWidget(covariant SwipeableCardStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset position khi đổi profile
    if (widget.currentProfile.userId != oldWidget.currentProfile.userId ||
        widget.currentProfile.photos.map((p) => p.url).join() != oldWidget.currentProfile.photos.map((p) => p.url).join()) {
      _resetPosition();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _resetPosition() {
    _offsetX = 0;
    _offsetY = 0;
    _highlightLike = false;
    _highlightPass = false;
    widget.onHighlightLike?.call(false);
    widget.onHighlightPass?.call(false);
  }

  void _onDragStart(DragStartDetails details) {
    if (_isAnimating) return;
    _highlightLike = false;
    _highlightPass = false;
    widget.onHighlightLike?.call(false);
    widget.onHighlightPass?.call(false);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    setState(() {
      _offsetX += details.delta.dx;
      _offsetY += details.delta.dy;
      _offsetY = _offsetY.clamp(-50, 50);
      _highlightLike = _offsetX > peekThreshold;
      _highlightPass = _offsetX < -peekThreshold;
    });
    widget.onHighlightLike?.call(_highlightLike);
    widget.onHighlightPass?.call(_highlightPass);
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isAnimating) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final shouldSwipe = _offsetX.abs() > swipeThreshold || velocity.abs() > 500;
    if (shouldSwipe) {
      _isAnimating = true;
      final direction = _offsetX > 0 || velocity > 0 ? 1 : -1;
      final targetPosition = direction * 600.0;
      _anim = Tween<double>(
        begin: _offsetX,
        end: targetPosition,
      ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
      _animController.forward().then((_) {
        _isAnimating = false;
        _resetPosition();
        widget.onSwiped?.call();
      });
    } else {
      _isAnimating = true;
      _anim = Tween<double>(
        begin: _offsetX,
        end: 0.0,
      ).animate(CurvedAnimation(parent: _animController, curve: Curves.elasticOut));
      _animController.forward().then((_) {
        setState(() {
          _highlightLike = false;
          _highlightPass = false;
          _isAnimating = false;
        });
        widget.onHighlightLike?.call(false);
        widget.onHighlightPass?.call(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final angle = (_offsetX / 400) * maxAngle * 3.1416 / 180;
    final peekProgress = (_offsetX.abs() / swipeThreshold).clamp(0.0, 1.0);
    final nextCardScale = 0.9 + (0.1 * peekProgress);
    final nextCardOpacity = 0.3 + (0.7 * peekProgress);
    final nextCardOffset = 10.0 * peekProgress;
    final currentKey = 'profile_card_${widget.currentProfile.userId}_${widget.currentProfile.photos.map((p) => p.url).join()}';
    final nextKey = widget.nextProfile != null ? 'profile_card_${widget.nextProfile!.userId}_${widget.nextProfile!.photos.map((p) => p.url).join()}' : null;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (widget.nextProfile != null && widget.nextInterests != null)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: nextCardOpacity,
              duration: const Duration(milliseconds: 150),
              child: Transform.scale(
                scale: nextCardScale,
                child: Transform.translate(
                  offset: Offset(0, nextCardOffset),
                  child: ProfileCard(
                    key: ValueKey(nextKey),
                    profile: widget.nextProfile!,
                    interests: widget.nextInterests!,
                    distance: widget.nextDistance,
                  ),
                ),
              ),
            ),
          ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: GestureDetector(
            key: ValueKey(currentKey),
            onPanStart: _onDragStart,
            onPanUpdate: _onDragUpdate,
            onPanEnd: _onDragEnd,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_offsetX, _offsetY),
                  child: Transform.rotate(
                    angle: angle,
                    child: ProfileCard(
                      key: ValueKey(currentKey),
                      profile: widget.currentProfile,
                      interests: widget.currentInterests,
                      distance: widget.currentDistance,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (_highlightLike)
          Positioned(
            top: 50,
            right: 30,
            child: AnimatedOpacity(
              opacity: (_offsetX / swipeThreshold).clamp(0.0, 1.0),
              duration: const Duration(milliseconds: 150),
              child: Transform.rotate(
                angle: 0.3,
                child: _buildHighlightIcon(
                  Icons.favorite,
                  Colors.green,
                  'LIKE',
                ),
              ),
            ),
          ),
        if (_highlightPass)
          Positioned(
            top: 50,
            left: 30,
            child: AnimatedOpacity(
              opacity: (-_offsetX / swipeThreshold).clamp(0.0, 1.0),
              duration: const Duration(milliseconds: 150),
              child: Transform.rotate(
                angle: -0.3,
                child: _buildHighlightIcon(
                  Icons.close,
                  Colors.red,
                  'NOPE',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHighlightIcon(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
