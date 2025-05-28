// lib/presentation/profile/view/profile_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_viewmodel.dart';
import '../shared/profile_section_container.dart';
import '../shared/profile_location.dart';
import '../shared/profile_appearance.dart';
import '../shared/profile_job_education.dart';
import '../shared/profile_lifestyle.dart';
import '../shared/profile_interests_languages.dart';
import '../shared/profile_bio_photos.dart';
import 'widgets/profile_cover_avatar.dart';
import 'widgets/profile_main_info.dart';
import 'widgets/profile_bio_interests.dart';
import 'widgets/profile_accordion_section.dart';
import 'widgets/accordion_section_controller.dart';
import '../edit/edit_profile_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..loadProfile(),
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (vm.error != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Profile')),
              body: Center(child: Text(vm.error!)),
            );
          }
          // Sửa tại đây: nếu profile null thì show loading hoặc empty/error UI
          final profile = vm.profile;
          if (profile == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Profile')),
              body: const Center(child: Text('No profile data found.')),
            );
          }
          final AccordionSectionController _accordionController = AccordionSectionController();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Profile',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileView()),
                    );
                  },
                ),
              ],
            ),
            body: ListView(
              padding: EdgeInsets.zero,
              children: [
                ProfileCoverAvatar(
                  avatarUrl: profile.avatarUrl,
                  coverUrl: profile.coverUrl,
                ),
                ProfileMainInfo(
                  firstName: profile.firstName,
                  lastName: profile.lastName,
                  dob: profile.dateOfBirth,
                  gender: profile.gender,
                ),
                ProfileBioInterests(
                  bio: profile.bio,
                  interests: profile.interests,
                ),
                const SizedBox(height: 6),
                ProfileAccordionSection(
                  controller: _accordionController,
                  sectionKey: 'location',
                  title: 'Location',
                  icon: Icons.location_on_outlined,
                  child: ProfileSectionContainer(
                    margin: EdgeInsets.zero,
                    child: ProfileLocation(
                      city: profile.city,
                      state: profile.state,
                      country: profile.country,
                      locationPreference: profile.locationPreference,
                    ),
                  ),
                ),
                ProfileAccordionSection(
                  controller: _accordionController,
                  sectionKey: 'appearance',
                  title: 'Appearance',
                  icon: Icons.accessibility_new_rounded,
                  child: ProfileSectionContainer(
                    margin: EdgeInsets.zero,
                    child: ProfileAppearance(
                      bodyType: profile.bodyType,
                      height: profile.height,
                    ),
                  ),
                ),
                ProfileAccordionSection(
                  controller: _accordionController,
                  sectionKey: 'job',
                  title: 'Job & Education',
                  icon: Icons.work_outline_rounded,
                  child: ProfileSectionContainer(
                    margin: EdgeInsets.zero,
                    child: ProfileJobEducation(
                      jobIndustry: profile.jobIndustry,
                      educationLevel: profile.educationLevel,
                      dropOut: profile.dropOut,
                    ),
                  ),
                ),
                ProfileAccordionSection(
                  controller: _accordionController,
                  sectionKey: 'lifestyle',
                  title: 'Lifestyle',
                  icon: Icons.self_improvement_outlined,
                  child: ProfileSectionContainer(
                    margin: EdgeInsets.zero,
                    child: ProfileLifestyle(
                      drinkStatus: profile.drinkStatus,
                      smokeStatus: profile.smokeStatus,
                      pets: profile.pets,
                    ),
                  ),
                ),
                ProfileAccordionSection(
                  controller: _accordionController,
                  sectionKey: 'languages',
                  title: 'Languages',
                  icon: Icons.language,
                  child: ProfileSectionContainer(
                    margin: EdgeInsets.zero,
                    child: ProfileInterestsLanguages(
                      interests: null,
                      languages: profile.languages,
                      interestedInNewLanguage: profile.interestedInNewLanguage,
                    ),
                  ),
                ),
                ProfileAccordionSection(
                  controller: _accordionController,
                  sectionKey: 'photos',
                  title: 'Gallery Photos',
                  icon: Icons.photo_library_outlined,
                  child: ProfileSectionContainer(
                    margin: EdgeInsets.zero,
                    child: ProfileBioPhotos(
                      bio: null,
                      galleryPhotos: profile.galleryPhotos,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],
            ),
          );
        },
      ),
    );
  }
}