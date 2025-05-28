import 'package:flutter/material.dart';
import '../../shared/widgets/app_gradient_background.dart';
import '../setup/theme/setup_profile_theme.dart';
import '../shared/widgets/collapsible_section.dart';
import '../shared/profile_avatar_cover.dart';
import '../shared/profile_basic_info.dart';
import '../shared/profile_bio_photos.dart';
import '../shared/profile_location.dart';
import '../shared/profile_appearance.dart';
import '../shared/profile_job_education.dart';
import '../shared/profile_lifestyle.dart';
import '../shared/profile_interests_languages.dart';
import 'widgets/profile_action_menu.dart';

class ProfileView extends StatefulWidget {
  final dynamic profile;
  final bool isMyProfile;

  const ProfileView({
    super.key,
    required this.profile,
    required this.isMyProfile,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? _expandedSection;

  void _toggleSection(String section) {
    setState(() {
      if (_expandedSection == section) {
        _expandedSection = null;
      } else {
        _expandedSection = section;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = [
      if (widget.profile?.firstName?.isNotEmpty ?? false) widget.profile.firstName,
      if (widget.profile?.lastName?.isNotEmpty ?? false) widget.profile.lastName,
    ].join(' ');

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Profile', style: TextStyle(
            color: ProfileTheme.darkPurple,
            fontWeight: FontWeight.bold,
          )),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (widget.isMyProfile)
              IconButton(
                icon: Icon(Icons.edit, color: ProfileTheme.darkPink),
                tooltip: 'Edit Profile',
                onPressed: () {
                  Navigator.of(context).pushNamed('/edit-profile', arguments: widget.profile);
                },
              )
            else
              IconButton(
                icon: Icon(Icons.more_vert, color: ProfileTheme.darkPink),
                onPressed: () {
                  showProfileActionMenu(context, widget.profile);
                },
                tooltip: 'More Options',
              ),
          ],
        ),
        body: ListView(
          children: [
            ProfileAvatarCover(
              avatarUrl: widget.profile?.avatarUrl,
              coverUrl: widget.profile?.coverUrl,
              onViewCover: () {
                // View full cover photo (could navigate to a full-screen image view)
                if (widget.profile?.coverUrl != null) {
                  // Implementation for viewing full size cover photo
                }
              },
            ),

            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                displayName.isNotEmpty ? displayName : '-',
                style: ProfileTheme.getTitleStyle(context),
                textAlign: TextAlign.center,
              ),
            ),

            if (widget.profile?.username != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '@${widget.profile.username}',
                  style: TextStyle(color: ProfileTheme.darkPink),
                  textAlign: TextAlign.center,
                ),
              ),

            // Bio & Photos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProfileBioPhotos(
                bio: widget.profile?.bio,
                galleryPhotos: widget.profile?.galleryPhotos,
                onViewPhoto: (url) {
                  // Navigate to photo viewer
                },
              ),
            ),

            const SizedBox(height: 16),

            // Basic Information (Collapsible)
            CollapsibleSection(
              title: "Basic Information",
              icon: Icons.person,
              initiallyExpanded: _expandedSection == 'basic',
              onToggle: () => _toggleSection('basic'),
              child: ProfileBasicInfo(
                firstName: widget.profile?.firstName,
                lastName: widget.profile?.lastName,
                username: widget.profile?.username,
                dob: widget.profile?.dateOfBirth,
                gender: widget.profile?.gender,
                orientation: widget.profile?.orientation,
              ),
            ),

            // Appearance
            CollapsibleSection(
              title: "Appearance",
              icon: Icons.accessibility_new,
              initiallyExpanded: _expandedSection == 'appearance',
              onToggle: () => _toggleSection('appearance'),
              child: ProfileAppearance(
                bodyType: widget.profile?.bodyType,
                height: widget.profile?.height,
              ),
            ),

            // Location
            CollapsibleSection(
              title: "Location",
              icon: Icons.location_on,
              initiallyExpanded: _expandedSection == 'location',
              onToggle: () => _toggleSection('location'),
              child: ProfileLocation(
                city: widget.profile?.city,
                state: widget.profile?.state,
                country: widget.profile?.country,
                locationPreference: widget.profile?.locationPreference,
              ),
            ),

            // Job & Education
            CollapsibleSection(
              title: "Job & Education",
              icon: Icons.work,
              initiallyExpanded: _expandedSection == 'job',
              onToggle: () => _toggleSection('job'),
              child: ProfileJobEducation(
                jobIndustry: widget.profile?.jobIndustry,
                educationLevel: widget.profile?.educationLevel,
                dropOut: widget.profile?.dropOut,
              ),
            ),

            // Lifestyle
            CollapsibleSection(
              title: "Lifestyle",
              icon: Icons.emoji_emotions,
              initiallyExpanded: _expandedSection == 'lifestyle',
              onToggle: () => _toggleSection('lifestyle'),
              child: ProfileLifestyle(
                drinkStatus: widget.profile?.drinkStatus,
                smokeStatus: widget.profile?.smokeStatus,
                pets: widget.profile?.pets,
              ),
            ),

            // Interests & Languages
            CollapsibleSection(
              title: "Interests & Languages",
              icon: Icons.interests,
              initiallyExpanded: _expandedSection == 'interests',
              onToggle: () => _toggleSection('interests'),
              child: ProfileInterestsLanguages(
                interests: widget.profile?.interests,
                languages: widget.profile?.languages,
                interestedInNewLanguage: widget.profile?.interestedInNewLanguage,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}