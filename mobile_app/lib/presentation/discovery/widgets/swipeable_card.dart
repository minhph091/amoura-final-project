import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/profile/interest_model.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import '../../../infrastructure/services/cache_cleanup_service.dart';
import '../../../infrastructure/services/profile_transition_manager.dart';
import 'profile_card.dart';
import 'profile_card_wrapper.dart';

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
  bool _isDragging = false;

  static const double swipeThreshold = 100;
  static const double maxAngle = 15;
  static const double peekThreshold = 20;
  static const double maxVerticalOffset = 30; // Giới hạn vuốt dọc

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Giảm thời gian animation
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
    
    // Detect profile change
    final isNewProfile = widget.currentProfile.userId != oldWidget.currentProfile.userId;
    
    if (isNewProfile) {
      // Kết thúc transition cho profile cũ
      ProfileTransitionManager.instance.endTransition(widget.currentProfile);
      
      // Reset position và animation
      _resetPosition();
      
      // Reset animation controller
      _animController.reset();
      
      // Force rebuild để đảm bảo UI được clear hoàn toàn
      if (mounted) {
        setState(() {});
      }
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
    _isDragging = false;
    widget.onHighlightLike?.call(false);
    widget.onHighlightPass?.call(false);
  }

  void _onDragStart(DragStartDetails details) {
    if (_isAnimating) return;
    
    _isDragging = true;
    
    // Bắt đầu transition ngay khi bắt đầu vuốt
    ProfileTransitionManager.instance.startTransition(widget.currentProfile);
    
    _highlightLike = false;
    _highlightPass = false;
    widget.onHighlightLike?.call(false);
    widget.onHighlightPass?.call(false);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isAnimating || !_isDragging) return;
    
    setState(() {
      // Chỉ cho phép vuốt ngang (trái/phải)
      _offsetX += details.delta.dx;
      
      // Vuốt dọc chỉ di chuyển trong phạm vi giới hạn và không trigger swipe
      _offsetY += details.delta.dy;
      _offsetY = _offsetY.clamp(-maxVerticalOffset, maxVerticalOffset);
      
      // Chỉ highlight khi vuốt ngang đủ xa
      _highlightLike = _offsetX > peekThreshold;
      _highlightPass = _offsetX < -peekThreshold;
    });
    
    widget.onHighlightLike?.call(_highlightLike);
    widget.onHighlightPass?.call(_highlightPass);
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isAnimating || !_isDragging) return;
    
    _isDragging = false;
    
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
        
        // Kết thúc transition khi vuốt xong
        if (widget.nextProfile != null) {
          ProfileTransitionManager.instance.endTransition(widget.nextProfile!);
        }
        
        widget.onSwiped?.call();
      });
    } else {
      // Reset về vị trí ban đầu
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
    
    // Tạo unique key cho current profile
    final currentKey = 'profile_${widget.currentProfile.userId}_${widget.currentProfile.photos.map((p) => p.id).join('_')}';
    final nextKey = widget.nextProfile != null ? 'profile_${widget.nextProfile!.userId}_${widget.nextProfile!.photos.map((p) => p.id).join('_')}' : null;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Next card (background)
        if (widget.nextProfile != null && widget.nextInterests != null)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: nextCardOpacity,
              duration: const Duration(milliseconds: 150),
              child: Transform.scale(
                scale: nextCardScale,
                child: Transform.translate(
                  offset: Offset(0, nextCardOffset),
                  child: ProfileCardWrapper(
                    key: ValueKey(nextKey),
                    profile: widget.nextProfile!,
                    interests: widget.nextInterests!,
                    distance: widget.nextDistance,
                  ),
                ),
              ),
            ),
          ),
        // Current card (swipeable)
        Positioned.fill(
          child: GestureDetector(
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
                    child: ProfileCardWrapper(
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
        // Like highlight
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
        // Pass highlight
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
