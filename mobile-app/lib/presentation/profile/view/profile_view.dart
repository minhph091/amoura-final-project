// lib/presentation/profile/view/profile_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'profile_viewmodel.dart';
import '../edit/edit_profile_view.dart';

class ProfileView extends StatefulWidget {
  final bool isMyProfile;

  const ProfileView({
    super.key,
    required this.isMyProfile,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? _expandedSection = 'basic'; // Default to expand the basic info section

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
  void initState() {
    super.initState();
    // Trigger profile loading after the first frame is built
    // Comment: This ensures profile data is loaded from the API when the view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileViewModel>(context, listen: false).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  final profile = Provider.of<ProfileViewModel>(context, listen: false).profile;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditProfileView(profile: profile),
                    ),
                  );
                },
              )
            else
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.more_vert),
                  ),
                  tooltip: 'More Options',
                  onPressed: () {
                    showProfileActionMenu(context, Provider.of<ProfileViewModel>(context, listen: false).profile);
                  },
                ),
              ),
          ],
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.error != null) {
              return Center(child: Text('Error: ${viewModel.error}'));
            } else if (viewModel.profile != null) {
              final profile = viewModel.profile!;
              final displayName = [
                if (profile['firstName']?.isNotEmpty ?? false) profile['firstName'],
                if (profile['lastName']?.isNotEmpty ?? false) profile['lastName'],
              ].join(' ');

              return ListView(
                children: [
                  ProfileAvatarCover(
                    avatarUrl: profile['avatarUrl'] as String?,
                    coverUrl: profile['coverUrl'] as String?,
                    onViewCover: () {
                      if (profile['coverUrl'] != null) {
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

                  if (profile['username'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '@${profile['username']}',
                        style: TextStyle(color: ProfileTheme.darkPink),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Basic Information (Collapsible)
                  CollapsibleSection(
                    title: "Basic Information",
                    icon: Icons.person,
                    initiallyExpanded: _expandedSection == 'basic',
                    onToggle: () => _toggleSection('basic'),
                    child: ProfileBasicInfo(
                      firstName: profile['firstName'] as String?,
                      lastName: profile['lastName'] as String?,
                      username: profile['username'] as String?,
                      dob: profile['dateOfBirth'] != null
                          ? DateTime.tryParse(profile['dateOfBirth'] as String)
                          : null,
                      gender: profile['sex'] as String?,
                      orientation: profile['orientation'] != null
                          ? (profile['orientation'] as Map<String, dynamic>)['name'] as String?
                          : null,
                    ),
                  ),

                  // Bio & Photos
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ProfileBioPhotos(
                      bio: profile['bio'] as String?,
                      galleryPhotos: (profile['galleryPhotos'] as List<dynamic>?)?.cast<String>(),
                      onViewPhoto: (url) {
                        // Navigate to photo viewer
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Appearance
                  CollapsibleSection(
                    title: "Appearance",
                    icon: Icons.accessibility_new,
                    initiallyExpanded: _expandedSection == 'appearance',
                    onToggle: () => _toggleSection('appearance'),
                    child: ProfileAppearance(
                      bodyType: profile['bodyType'] != null
                          ? (profile['bodyType'] as Map<String, dynamic>)['name'] as String?
                          : null,
                      height: profile['height'] != null 
                          ? int.tryParse(profile['height'].toString())
                          : null,
                    ),
                  ),

                  // Location
                  CollapsibleSection(
                    title: "Location",
                    icon: Icons.location_on,
                    initiallyExpanded: _expandedSection == 'location',
                    onToggle: () => _toggleSection('location'),
                    child: ProfileLocation(
                      city: profile['location'] != null ? (profile['location'] as Map<String, dynamic>)['city'] as String? : null,
                      state: profile['location'] != null ? (profile['location'] as Map<String, dynamic>)['state'] as String? : null,
                      country: profile['location'] != null ? (profile['location'] as Map<String, dynamic>)['country'] as String? : null,
                      locationPreference: profile['locationPreference'] as int?,
                    ),
                  ),

                  // Job & Education
                  CollapsibleSection(
                    title: "Job & Education",
                    icon: Icons.work,
                    initiallyExpanded: _expandedSection == 'job',
                    onToggle: () => _toggleSection('job'),
                    child: ProfileJobEducation(
                      jobIndustry: profile['jobIndustry'] != null
                          ? (profile['jobIndustry'] as Map<String, dynamic>)['name'] as String?
                          : null,
                      educationLevel: profile['educationLevel'] != null
                          ? (profile['educationLevel'] as Map<String, dynamic>)['name'] as String?
                          : null,
                      dropOut: profile['dropOut'] as bool?,
                    ),
                  ),

                  // Lifestyle
                  CollapsibleSection(
                    title: "Lifestyle",
                    icon: Icons.emoji_emotions,
                    initiallyExpanded: _expandedSection == 'lifestyle',
                    onToggle: () => _toggleSection('lifestyle'),
                    child: ProfileLifestyle(
                      drinkStatus: profile['drinkStatus'] != null
                          ? (profile['drinkStatus'] as Map<String, dynamic>)['name'] as String?
                          : null,
                      smokeStatus: profile['smokeStatus'] != null
                          ? (profile['smokeStatus'] as Map<String, dynamic>)['name'] as String?
                          : null,
                      pets: (profile['pets'] as List<dynamic>?)?.map((pet) => (pet as Map<String, dynamic>)['name'] as String).toList(),
                    ),
                  ),

                  // Interests & Languages
                  CollapsibleSection(
                    title: "Interests & Languages",
                    icon: Icons.interests,
                    initiallyExpanded: _expandedSection == 'interests',
                    onToggle: () => _toggleSection('interests'),
                    child: ProfileInterestsLanguages(
                      interests: (profile['interests'] as List<dynamic>?)?.map((interest) => (interest as Map<String, dynamic>)['name'] as String).toList(),
                      languages: (profile['languages'] as List<dynamic>?)?.map((language) => (language as Map<String, dynamic>)['name'] as String).toList(),
                      interestedInNewLanguage: profile['interestedInNewLanguage'] as bool?,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              );
            } else {
              return const Center(child: Text('No profile data available'));
            }
          },
        ),
      ),
    );
  }
}