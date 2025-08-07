// lib/presentation/discovery/widgets/profile_card.dart
// Discovery profile card, correct vertical layout and scroll.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../data/models/profile/interest_model.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import '../../../core/utils/date_util.dart';
import '../../../core/services/profile_service.dart';
import '../../../app/di/injection.dart';
import 'image_carousel.dart';
import 'profile_detail_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../profile/view/profile_viewmodel.dart';
import '../../../config/language/app_localizations.dart';
import 'profile_detail_page.dart';

// Đổi từ StatelessWidget sang StatefulWidget để tối ưu performance
class ProfileCard extends StatefulWidget {
  final UserRecommendationModel profile;
  final List<InterestModel> interests;
  final String? distance;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.interests,
    this.distance,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  List<String>? _commonInterests;
  bool _isLoadingInterests = false;

  @override
  void initState() {
    super.initState();
    _loadCommonInterests();
  }

  @override
  void didUpdateWidget(covariant ProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Chỉ load lại common interests nếu profile thay đổi
    if (oldWidget.profile.userId != widget.profile.userId) {
      _loadCommonInterests();
    }
  }

  /// Tìm common interests giữa current user và recommendation user
  Future<void> _loadCommonInterests() async {
    if (_isLoadingInterests) return;
    
    setState(() {
      _isLoadingInterests = true;
    });

    try {
      final profileService = getIt<ProfileService>();
      final currentUserProfile = await profileService.getProfile();

      // Extract current user interests
      final currentUserInterests = <String>[];
      if (currentUserProfile['interests'] != null) {
        final interestsList = currentUserProfile['interests'] as List;
        currentUserInterests.addAll(
          interestsList.map((i) => i['name'].toString().toLowerCase()).toList(),
        );
      }

      // Extract recommendation user interests
      final recommendationInterests =
          widget.profile.interests.map((i) => i.name.toLowerCase()).toList();

      // Find common interests (max 3)
      final commonInterests =
          currentUserInterests
              .where((interest) => recommendationInterests.contains(interest))
              .take(3)
              .toList();

      if (mounted) {
        setState(() {
          _commonInterests = commonInterests;
          _isLoadingInterests = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _commonInterests = [];
          _isLoadingInterests = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ageText =
        widget.profile.age != null
            ? ', ${widget.profile.age}'
            : (widget.profile.dateOfBirth != null
                ? ', ${DateUtil.calculateAge(widget.profile.dateOfBirth!)}'
                : '');
    final displayLocation = widget.distance ?? widget.profile.location ?? 'Unknown';
    final bio =
        widget.profile.bio?.isNotEmpty == true
            ? widget.profile.bio!
            : 'Always ready for an adventure!';
    final name = widget.profile.fullName;

    // --- Filter and sort photos: cover first, then up to 4 highlights by uploadedAt ---
    final coverList =
        widget.profile.photos.where((p) => p.type == 'profile_cover').toList();
    final cover = coverList.isNotEmpty ? coverList.first : null;
    final highlights =
        widget.profile.photos.where((p) => p.type == 'highlight').toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final displayPhotos = [if (cover != null) cover, ...highlights.take(4)];

    // Controller for resetting image index
    final ImageCarouselController imageController = ImageCarouselController();

    // Tạo unique key stable nhưng unique cho mỗi profile
    final uniqueKey = 'profile_${widget.profile.userId}_${widget.profile.photos.map((p) => p.id).join('_')}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          // Main image carousel with story progress bar
          ImageCarousel(
            key: ValueKey('${uniqueKey}_carousel'),
            photos: displayPhotos,
            showStoryProgress: true,
            controller: imageController,
            uniqueKey: uniqueKey,
          ),
          // Overlay user info - thêm lại blur nhẹ để tránh loading khi click ảnh
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), // Blur nhẹ hơn để tránh loading
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 1.0],
                    ),
                  ),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              '$name$ageText',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () async {
                              // Sử dụng Navigator.push thay vì showModalBottomSheet để tránh widget tree issues
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileDetailPage(
                                    profile: widget.profile,
                                    interests: widget.interests,
                                    distance: widget.distance,
                                  ),
                                ),
                              );
                            },
                            tooltip: 'Xem thông tin chi tiết',
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            displayLocation,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (bio.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          bio,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Common interests section - sử dụng cached data
                      if (_commonInterests != null && _commonInterests!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).translate('common_interests'),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: _commonInterests!.map((interest) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.red.withOpacity(0.8),
                                        Colors.pink.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.6),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    interest,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      shadows: [
                                        const Shadow(
                                          color: Colors.black,
                                          blurRadius: 2,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      // Giảm padding bottom để thông tin ở thấp hơn như ảnh mẫu
                      const SizedBox(height: 60), // Giảm từ 90 xuống 60
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
