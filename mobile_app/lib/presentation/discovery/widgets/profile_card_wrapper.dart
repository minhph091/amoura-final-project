// lib/presentation/discovery/widgets/profile_card_wrapper.dart
import 'package:flutter/material.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import '../../../data/models/profile/interest_model.dart';
import '../../../infrastructure/services/cache_cleanup_service.dart';
import 'profile_card.dart';

class ProfileCardWrapper extends StatefulWidget {
  final UserRecommendationModel profile;
  final List<InterestModel> interests;
  final String? distance;

  const ProfileCardWrapper({
    super.key,
    required this.profile,
    required this.interests,
    this.distance,
  });

  @override
  State<ProfileCardWrapper> createState() => _ProfileCardWrapperState();
}

class _ProfileCardWrapperState extends State<ProfileCardWrapper> {
  String? _lastProfileKey;

  @override
  void initState() {
    super.initState();
    _lastProfileKey = _getProfileKey(widget.profile);
  }

  @override
  void didUpdateWidget(covariant ProfileCardWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final newProfileKey = _getProfileKey(widget.profile);
    final isNewProfile = newProfileKey != _lastProfileKey;
    
    if (isNewProfile) {
      // Clear cache của profile cũ
      CacheCleanupService.instance.clearProfileCache(oldWidget.profile);
      
      // Update tracking
      _lastProfileKey = newProfileKey;
      
      // Force rebuild để đảm bảo UI được clear hoàn toàn
      if (mounted) {
        setState(() {});
      }
    }
  }

  String _getProfileKey(UserRecommendationModel profile) {
    return '${profile.userId}_${profile.photos.map((p) => p.id).join('_')}';
  }

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      key: ValueKey(_getProfileKey(widget.profile)),
      profile: widget.profile,
      interests: widget.interests,
      distance: widget.distance,
    );
  }
} 