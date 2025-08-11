// lib/presentation/discovery/widgets/profile_card.dart
// Discovery profile card, correct vertical layout and scroll.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../data/models/profile/interest_model.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import '../../../core/utils/date_util.dart';
import 'image_carousel.dart';
import 'profile_detail_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import '../../profile/view/profile_viewmodel.dart';
import '../../../config/language/app_localizations.dart';
import 'profile_detail_page.dart';

// Đổi từ StatelessWidget sang StatefulWidget để tối ưu performance
class ProfileCard extends StatefulWidget {
  final UserRecommendationModel profile;
  final List<InterestModel> interests;
  final String? distance;
  final List<String> commonInterests;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.interests,
    this.distance,
    this.commonInterests = const [],
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  List<String> _commonInterests = const [];
  int _currentPhotoIndex = 0; // Theo dõi ảnh hiện tại để thay đổi info hiển thị
  bool _isBioExpanded = false; // Trạng thái mở rộng bio

  @override
  void initState() {
    super.initState();
    // Common interests được precompute trong buffer; đọc từ context khi build
  }

  @override
  void didUpdateWidget(covariant ProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.userId != widget.profile.userId) {
      // Reset trạng thái khi chuyển sang profile mới
      _isBioExpanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy common interests đã được precompute từ props
    _commonInterests = widget.commonInterests;

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
            onImageIndexChanged: (idx) {
              setState(() {
                _currentPhotoIndex = idx;
              });
            },
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
                      // Thay đổi nội dung hiển thị theo ảnh hiện tại:
                      //  - Ảnh 1: hiển thị vị trí + sở thích chung (ẩn bio theo yêu cầu)
                      //  - Ảnh 2: hiển thị học vấn + uống rượu/hút thuốc (ẩn bio)
                      //  - Ảnh 3: hiển thị thú cưng (ẩn bio)
                      //  - Ảnh khác: fallback sở thích chung
                      const SizedBox(height: 12),
                      ..._buildInfoByPhotoIndex(context, _currentPhotoIndex, bio),
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

  List<Widget> _buildInfoByPhotoIndex(BuildContext context, int index, String bio) {
    final List<Widget> widgets = [];
    // Common interests prepared earlier
    final hasCommon = _commonInterests.isNotEmpty;

    if (index == 0) {
      // Ảnh 1: vị trí đã hiển thị phía trên; hiển thị sở thích chung + bio (bio tối đa 2 dòng, có 'See more')
      if (hasCommon) {
        widgets.addAll(_buildCommonInterestsSection(context));
      }
      if (bio.isNotEmpty) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(_buildBioSection(context, bio));
      }
    } else if (index == 1) {
      // Ảnh 2: Học vấn + Lifestyle (drink/smoke)
      widgets.addAll(_buildEducationAndLifestyleSection(context));
    } else if (index == 2) {
      // Ảnh 3: Thú cưng
      widgets.addAll(_buildPetsSection(context));
    } else {
      // Fallback: sở thích chung nếu có
      if (hasCommon) {
        widgets.addAll(_buildCommonInterestsSection(context));
      }
    }

    return widgets;
  }

  List<Widget> _buildCommonInterestsSection(BuildContext context) {
    if (_commonInterests == null || _commonInterests!.isEmpty) return [];
    return [
      const SizedBox(height: 4),
      Text(
        AppLocalizations.of(context).translate('common_interests'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              border: Border.all(color: Colors.red.withOpacity(0.6), width: 1),
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    shadows: const [
                      Shadow(color: Colors.black, blurRadius: 2, offset: Offset(0, 1)),
                    ],
                  ),
            ),
          );
        }).toList(),
      ),
    ];
  }

  List<Widget> _buildEducationAndLifestyleSection(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    // Hiện tại hồ sơ đề xuất không có trực tiếp education/drink/smoke trong model,
    // nên hiển thị placeholder từ ngôn ngữ hoặc dấu '-'
    return [
      Row(
        children: [
          const Icon(Icons.school, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text(
            localizations.translate('job_education'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            '-',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Icon(Icons.local_bar, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text(
            localizations.translate('do_you_drink'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(width: 8),
          Text('-', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9))),
          const SizedBox(width: 16),
          const Icon(Icons.smoking_rooms, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text(
            localizations.translate('do_you_smoke'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(width: 8),
          Text('-', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9))),
        ],
      ),
    ];
  }

  List<Widget> _buildPetsSection(BuildContext context) {
    final pets = widget.profile.pets.map((e) => e.name).toList();
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.pets, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              pets.isNotEmpty ? pets.join(', ') : '-',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildBioSection(BuildContext context, String bio) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withOpacity(0.9),
          fontSize: 15,
        );
    final linkStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        );

    if (_isBioExpanded) {
      return RichText(
        text: TextSpan(
          style: textStyle,
          children: [
            TextSpan(text: bio),
            TextSpan(text: '  '),
            TextSpan(
              text: 'Show less',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  setState(() {
                    _isBioExpanded = false;
                  });
                },
            ),
          ],
        ),
      );
    }

    // Thu gọn đúng 2 dòng và chèn " See more" ngay sau từ cuối cùng vừa đủ
    return LayoutBuilder(
      builder: (context, constraints) {
        final linkSpan = TextSpan(text: ' See more', style: linkStyle);
        int min = 0;
        int max = bio.length;
        int best = 0;

        // Binary search để tìm số ký tự tối đa khớp 2 lines khi cộng " See more"
        while (min <= max) {
          final mid = (min + max) >> 1;
          final tryText = bio.substring(0, mid).trimRight();
          final testSpan = TextSpan(
            style: textStyle,
            children: [
              TextSpan(text: tryText.isEmpty ? '' : ('$tryText…')),
              linkSpan,
            ],
          );
          final tp = TextPainter(
            text: testSpan,
            maxLines: 2,
            textDirection: TextDirection.ltr,
          );
          tp.layout(maxWidth: constraints.maxWidth);
          if (tp.didExceedMaxLines) {
            max = mid - 1;
          } else {
            best = mid;
            min = mid + 1;
          }
        }

        final visible = bio.substring(0, best).trimRight();
        return RichText(
          text: TextSpan(
            style: textStyle,
            children: [
              if (visible.isNotEmpty) TextSpan(text: '$visible…'),
              TextSpan(
                text: ' See more',
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(() {
                      _isBioExpanded = true;
                    });
                  },
              ),
            ],
          ),
        );
      },
    );
  }
}
