// lib/presentation/discovery/widgets/smooth_transition_wrapper.dart
import 'package:flutter/material.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import '../../../data/models/profile/interest_model.dart';
import '../../../infrastructure/services/profile_transition_manager.dart';
import 'swipeable_card.dart';

class SmoothTransitionWrapper extends StatefulWidget {
  final UserRecommendationModel currentProfile;
  final List<InterestModel> currentInterests;
  final String? currentDistance;
  final UserRecommendationModel? nextProfile;
  final List<InterestModel>? nextInterests;
  final String? nextDistance;
  final void Function(bool)? onHighlightLike;
  final void Function(bool)? onHighlightPass;
  final VoidCallback? onSwiped;

  const SmoothTransitionWrapper({
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
  State<SmoothTransitionWrapper> createState() => _SmoothTransitionWrapperState();
}

class _SmoothTransitionWrapperState extends State<SmoothTransitionWrapper> {
  String? _lastProfileKey;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _lastProfileKey = _getProfileKey(widget.currentProfile);
  }

  @override
  void didUpdateWidget(covariant SmoothTransitionWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final newProfileKey = _getProfileKey(widget.currentProfile);
    final isNewProfile = newProfileKey != _lastProfileKey;
    
    if (isNewProfile) {
      // Bắt đầu transition
      _isTransitioning = true;
      
      // Clear cache và chuẩn bị cho profile mới
      ProfileTransitionManager.instance.clearAllCache();
      
      // Update tracking
      _lastProfileKey = newProfileKey;
      
      // Force rebuild
      if (mounted) {
        setState(() {});
      }
      
      // Kết thúc transition sau một khoảng thời gian ngắn
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _isTransitioning = false;
          });
        }
      });
    }
  }

  String _getProfileKey(UserRecommendationModel profile) {
    return '${profile.userId}_${profile.photos.map((p) => p.id).join('_')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isTransitioning) {
      // Hiển thị loading indicator khi đang transition
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return SwipeableCardStack(
      key: ValueKey(_getProfileKey(widget.currentProfile)),
      currentProfile: widget.currentProfile,
      currentInterests: widget.currentInterests,
      currentDistance: widget.currentDistance,
      nextProfile: widget.nextProfile,
      nextInterests: widget.nextInterests,
      nextDistance: widget.nextDistance,
      onHighlightLike: widget.onHighlightLike,
      onHighlightPass: widget.onHighlightPass,
      onSwiped: widget.onSwiped,
    );
  }
} 