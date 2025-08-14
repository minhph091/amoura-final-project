// lib/presentation/discovery/widgets/simple_swipeable_card.dart
import 'package:flutter/material.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import '../../../data/models/profile/interest_model.dart';
import 'profile_card.dart';

class SimpleSwipeableCard extends StatefulWidget {
  final UserRecommendationModel currentProfile;
  final List<InterestModel> currentInterests;
  final String? currentDistance;
  final List<String> currentCommonInterests;
  final UserRecommendationModel? nextProfile;
  final List<InterestModel>? nextInterests;
  final String? nextDistance;
  final List<String>? nextCommonInterests;
  final VoidCallback? onSwiped;
  final Function(bool isLike)? onSwipeDirection;
  final Function(double offset)? onSwipeProgress; // Track swipe progress
  final VoidCallback? onSwipeReset; // Reset when cancelled
  // New: notify final swipe result to parent (true = like/right, false = pass/left)
  final Function(bool isLike)? onSwipeCompleted;

  const SimpleSwipeableCard({
    super.key,
    required this.currentProfile,
    required this.currentInterests,
    this.currentDistance,
    this.currentCommonInterests = const [],
    this.nextProfile,
    this.nextInterests,
    this.nextDistance,
    this.nextCommonInterests,
    this.onSwiped,
    this.onSwipeDirection,
    this.onSwipeProgress,
    this.onSwipeReset,
    this.onSwipeCompleted,
  });

  @override
  State<SimpleSwipeableCard> createState() => _SimpleSwipeableCardState();
}

class _SimpleSwipeableCardState extends State<SimpleSwipeableCard>
    with SingleTickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  // Drag state
  double _dragOffset = 0.0;
  bool _isDragging = false;
  static const double _swipeThreshold = 85.0; // giảm nhẹ để cảm giác nhạy hơn
  static const double _maxRotation = 0.1; // nhẹ hơn để mượt
  bool _isDismissed = false; // Ẩn ngay lập tức sau khi quẹt xong để tránh giật

  @override
  void initState() {
    super.initState();
    
    // Sửa animation cho mượt mà hơn
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 180), // nhanh hơn chút
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.0, 0.0), // Slide off screen
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // Curve mượt mà
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // Curve mượt mà
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: _maxRotation,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // Curve mượt mà
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) {
      return const SizedBox.shrink();
    }
    return RepaintBoundary(
      child: GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
        child: Stack(
        children: [
            // Fix overscroll glow/banding khi vuốt dọc trên thiết bị thật
            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: Colors.transparent),
              ),
            ),
          // Next card (background)
          if (widget.nextProfile != null)
            Positioned.fill(
              child: Transform.scale(
                scale: 0.95 + (0.06 * (_dragOffset.abs() / _swipeThreshold).clamp(0.0, 1.0)),
                child: Opacity(
                  opacity: 0.45 + (0.55 * (_dragOffset.abs() / _swipeThreshold).clamp(0.0, 1.0)),
                  child: ProfileCard(
                    key: ValueKey('next_${widget.nextProfile!.userId}'),
                    profile: widget.nextProfile!,
                    interests: widget.nextInterests ?? [],
                    distance: widget.nextDistance,
                    commonInterests: widget.nextCommonInterests ?? const [],
                  ),
                ),
              ),
            ),

          // Current card (swipeable)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: _isDragging 
                  ? Offset(_dragOffset, 0.0)
                  : _slideAnimation.value * MediaQuery.of(context).size.width,
                child: Transform.rotate(
                  angle: _isDragging
                    ? (_dragOffset / _swipeThreshold).clamp(-1.0, 1.0) * _maxRotation
                    : (_dragOffset > 0 ? _rotationAnimation.value : -_rotationAnimation.value),
                  child: Transform.scale(
                    scale: _isDragging ? 1.0 : _scaleAnimation.value,
                    child: ProfileCard(
                      key: ValueKey('current_${widget.currentProfile.userId}'),
                      profile: widget.currentProfile,
                      interests: widget.currentInterests,
                      distance: widget.currentDistance,
                      commonInterests: widget.currentCommonInterests,
                    ),
                  ),
                ),
              );
            },
          ),

          // Swipe indicators
          if (_isDragging && _dragOffset.abs() > 20)
            Positioned.fill(
              child: _buildSwipeIndicators(),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    final opacity = (_dragOffset.abs() / _swipeThreshold).clamp(0.0, 1.0);
    
    return Stack(
      children: [
        // Like indicator (right swipe)
        if (_dragOffset > 20)
          Positioned(
            top: 100,
            right: 30,
            child: Transform.rotate(
              angle: 0.3,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    border: Border.all(color: Colors.green, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, color: Colors.green, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'LIKE',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Pass indicator (left swipe)
        if (_dragOffset < -20)
          Positioned(
            top: 100,
            left: 30,
            child: Transform.rotate(
              angle: -0.3,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    border: Border.all(color: Colors.red, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, color: Colors.red, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'PASS',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _animationController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    setState(() {
      _dragOffset += details.delta.dx;
    });
    
    // Call progress callback for smooth highlighting
    if (widget.onSwipeProgress != null) {
      widget.onSwipeProgress!(_dragOffset);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;
    
    _isDragging = false;
    
    // Check if swipe threshold reached - threshold nhỏ hơn cho dễ vuốt
    final isSwipe = _dragOffset.abs() > 75; // hạ ngưỡng nhẹ
    final velocity = details.velocity.pixelsPerSecond.dx.abs();
    final isFastSwipe = velocity > 350; // hạ ngưỡng nhẹ
    
    if (isSwipe || isFastSwipe) {
      final bool isLike = _dragOffset > 0;
      // Complete the swipe animation
      _animationController.forward().then((_) {
        if (!mounted) return;
        setState(() {
          _isDismissed = true; // Ẩn card ngay lập tức, tránh "quay ngược" trước khi đóng
        });
        
        // Reset button highlights via callback
        widget.onSwipeReset?.call();
        
        // Notify parent
        widget.onSwipeCompleted?.call(isLike);
        widget.onSwiped?.call();
      });
    } else {
      // Snap back to center
      _animationController.reverse().then((_) {
        setState(() {
          _dragOffset = 0.0;
        });
        
        // Reset button highlights via callback
        widget.onSwipeReset?.call();
      });
    }
  }
}
