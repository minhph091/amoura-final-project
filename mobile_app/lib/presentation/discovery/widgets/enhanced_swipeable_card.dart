// lib/presentation/discovery/widgets/enhanced_swipeable_card.dart
import 'package:flutter/material.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import '../../../data/models/profile/interest_model.dart';
import 'profile_card.dart';

class EnhancedSwipeableCard extends StatefulWidget {
  final UserRecommendationModel currentProfile;
  final List<InterestModel> currentInterests;
  final String? currentDistance;
  final UserRecommendationModel? nextProfile;
  final List<InterestModel>? nextInterests;
  final String? nextDistance;
  final VoidCallback? onSwiped;
  final Function(bool isLike)? onSwipeDirection; // Callback for swipe direction

  const EnhancedSwipeableCard({
    super.key,
    required this.currentProfile,
    required this.currentInterests,
    this.currentDistance,
    this.nextProfile,
    this.nextInterests,
    this.nextDistance,
    this.onSwiped,
    this.onSwipeDirection,
  });

  @override
  State<EnhancedSwipeableCard> createState() => _EnhancedSwipeableCardState();
}

class _EnhancedSwipeableCardState extends State<EnhancedSwipeableCard>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  Offset _dragStartPosition = Offset.zero;
  bool _isDragging = false;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    
    _positionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _dragStartPosition = details.localPosition;
    _isDragging = true;
    _scaleController.forward();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final deltaX = details.localPosition.dx - _dragStartPosition.dx;
    final deltaY = details.localPosition.dy - _dragStartPosition.dy;
    _dragDistance = deltaX.abs();

    // Update slide animation
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(deltaX / 300, deltaY / 300),
    ).animate(_positionController);

    // Update rotation based on horizontal movement
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: (deltaX / 300) * 0.3, // Max rotation of ~17 degrees
    ).animate(_positionController);

    // Trigger swipe direction callback
    if (_dragDistance > 50) {
      final isLike = deltaX > 0;
      widget.onSwipeDirection?.call(isLike);
    }

    _positionController.value = (_dragDistance / 150).clamp(0.0, 1.0);
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    _scaleController.reverse();

    if (_dragDistance > 120) {
      // Complete the swipe
      _positionController.forward().then((_) {
        widget.onSwiped?.call();
      });
    } else {
      // Snap back to center
      _positionController.reverse();
      widget.onSwipeDirection?.call(false); // Reset button states
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_positionController, _scaleController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value * 300,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Stack(
                children: [
                  // Next card (behind current)
                  if (widget.nextProfile != null)
                    Opacity(
                      opacity: 0.8,
                      child: Transform.scale(
                        scale: 0.95,
                        child: ProfileCard(
                          profile: widget.nextProfile!,
                          interests: widget.nextInterests ?? [],
                          distance: widget.nextDistance,
                        ),
                      ),
                    ),
                  
                  // Current card (on top)
                  GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Stack(
                      children: [
                        ProfileCard(
                          profile: widget.currentProfile,
                          interests: widget.currentInterests,
                          distance: widget.currentDistance,
                        ),
                        
                        // Swipe indicators
                        if (_dragDistance > 50) ...[
                          // Like indicator (right swipe)
                          if (_slideAnimation.value.dx > 0)
                            Positioned(
                              top: 50,
                              right: 20,
                              child: Transform.rotate(
                                angle: -0.3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.green,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Text(
                                    'LIKE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          
                          // Pass indicator (left swipe)
                          if (_slideAnimation.value.dx < 0)
                            Positioned(
                              top: 50,
                              left: 20,
                              child: Transform.rotate(
                                angle: 0.3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Text(
                                    'PASS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
