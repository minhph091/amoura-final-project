// lib/presentation/discovery/widgets/profile_card.dart
// Discovery profile card, correct vertical layout and scroll.

import 'package:flutter/material.dart';
import '../../../data/models/profile/profile_model.dart';
import '../../../data/models/profile/interest_model.dart';
import '../../../core/constants/profile/interest_constants.dart';
import '../../../core/utils/date_util.dart';
import 'image_carousel.dart';
import 'user_info_section.dart';

class ProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final List<InterestModel> interests;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.interests,
  });

  @override
  Widget build(BuildContext context) {
    final age = profile.dateOfBirth != null
        ? DateUtil.calculateAge(profile.dateOfBirth!)
        : 0;
    final location = profile.locationPreference != null
        ? 'Within ${profile.locationPreference} km'
        : 'Unknown';
    final bio = profile.bio ?? 'No bio provided';
    final interestChips = interests
        .map((interest) {
      final interestOption = interestOptions.firstWhere(
            (option) => option['value'] == interest.name,
        orElse: () => {
          'label': interest.name,
          'icon': Icons.interests,
          'color': Colors.grey,
        },
      );
      return InterestChipData(
        label: interestOption['label'],
        icon: interestOption['icon'],
        iconColor: interestOption['color'],
        borderColor: interestOption['color'],
        gradient: LinearGradient(
          colors: [
            interestOption['color'].withValues(alpha: 0.1),
            interestOption['color'].withValues(alpha: 0.1),
          ],
        ),
      );
    })
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 17,
            right: 17,
            top: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(38),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 55,
                    spreadRadius: 12,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  const ImageCarousel(),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: UserInfoSection(
                      name: profile.userId.toString(), // Use userId as placeholder for name
                      age: age,
                      location: location,
                      bio: bio,
                      interests: interestChips,
                    ),
                  ),
                  Positioned(
                    top: 22,
                    right: 26,
                    child: Material(
                      shape: const CircleBorder(),
                      color: Colors.white.withValues(alpha: 0.21),
                      child: InkWell(
                        onTap: () {}, // Logic to be implemented by others
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          height: 44,
                          width: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.08),
                              width: 1.7,
                            ),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 26,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}