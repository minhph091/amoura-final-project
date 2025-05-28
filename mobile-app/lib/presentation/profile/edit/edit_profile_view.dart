// lib/presentation/profile/edit/edit_profile_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_profile_viewmodel.dart';
import 'widgets/edit_profile_cover_avatar.dart';
import 'widgets/edit_profile_main_info.dart';
import 'widgets/edit_profile_bio_interests.dart';
import 'widgets/edit_profile_accordion_section.dart';
import 'widgets/edit_profile_accordion_controller.dart';
import '../shared/profile_section_container.dart';
import '../shared/profile_location.dart';
import '../shared/profile_appearance.dart';
import '../shared/profile_job_education.dart';
import '../shared/profile_lifestyle.dart';
import '../shared/profile_interests_languages.dart';
import '../shared/profile_bio_photos.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileViewModel()..loadProfile(),
      child: Consumer<EditProfileViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (vm.error != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit Profile')),
              body: Center(child: Text('Error')),
            );
          }
          final profile = vm.profile;
          if (profile == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit Profile')),
              body: const Center(child: Text('No profile data found.')),
            );
          }
          final controller = EditProfileAccordionController();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.save_alt),
                  tooltip: 'Save',
                  onPressed: vm.isSaving
                      ? null
                      : () async {
                    await vm.saveProfile(profile);
                    if (vm.error == null) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
            body: ListView(
              padding: EdgeInsets.zero,
              children: [
                EditProfileCoverAvatar(
                  avatarUrl: profile.avatarUrl,
                  coverUrl: profile.coverUrl,
                  onEditAvatar: () {}, // TODO
                  onEditCover: () {}, // TODO
                ),
                EditProfileMainInfo(
                  firstName: profile.firstName,
                  lastName: profile.lastName,
                  dob: profile.dateOfBirth,
                  gender: profile.gender,
                  onEdit: (field) {}, // TODO: open edit dialog for each field
                ),
                EditProfileBioInterests(
                  bio: profile.bio,
                  interests: profile.interests,
                  onEditBio: () {}, // TODO
                  onEditInterests: () {}, // TODO
                ),
                const SizedBox(height: 6),
                EditProfileAccordionSection(
                  controller: controller,
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
                      editable: true,
                      onEdit: (field) {}, // TODO
                    ),
                  ),
                ),
                EditProfileAccordionSection(
                  controller: controller,
                  sectionKey: 'appearance',
                  title: 'Appearance',
                  icon: Icons.accessibility_new_rounded,
                  child: ProfileSectionContainer(
                    margin: EdgeInsets.zero,
                    child: ProfileAppearance(
                      bodyType: profile.bodyType,
                      height: profile.height,
                      editable: true,
                      onEdit: (field) {}, // TODO
                    ),
                  ),
                ),
                EditProfileAccordionSection(
                  controller: controller,
                  sectionKey: 'job',
                  title: 'Job & Education',
                  icon: Icons.work_outline_rounded,
                  child: ProfileSectionContainer(
                    margin: EdgeInsets.zero,
                    child: ProfileJobEducation(
                      jobIndustry: profile.jobIndustry,
                      educationLevel: profile.educationLevel,
                      dropOut: profile.dropOut,
                      editable: true,
                      onEdit: (field) {}, // TODO
                    ),
                  ),
                ),
                EditProfileAccordionSection(
                  controller: controller,
                  sectionKey: 'lifestyle',
                  title: 'Lifestyle',
                  icon: Icons.self_improvement_outlined,
                  child: ProfileSectionContainer(
                    margin: EdgeInsets.zero,
                    child: ProfileLifestyle(
                      drinkStatus: profile.drinkStatus,
                      smokeStatus: profile.smokeStatus,
                      pets: profile.pets,
                      editable: true,
                      onEdit: (field) {}, // TODO
                    ),
                  ),
                ),
                EditProfileAccordionSection(
                  controller: controller,
                  sectionKey: 'languages',
                  title: 'Languages',
                  icon: Icons.language,
                  child: ProfileSectionContainer(
                    margin: EdgeInsets.zero,
                    child: ProfileInterestsLanguages(
                      interests: profile.interests,
                      languages: profile.languages,
                      interestedInNewLanguage: profile.interestedInNewLanguage,
                      editable: true,
                      onEdit: (field) {}, // TODO
                    ),
                  ),
                ),
                EditProfileAccordionSection(
                  controller: controller,
                  sectionKey: 'photos',
                  title: 'Gallery Photos',
                  icon: Icons.photo_library_outlined,
                  child: ProfileSectionContainer(
                    margin: EdgeInsets.zero,
                    child: ProfileBioPhotos(
                      bio: profile.bio,
                      galleryPhotos: profile.galleryPhotos,
                      editable: true,
                      onEditBio: () {}, // TODO
                      onAddPhoto: () {}, // TODO
                      onRemovePhoto: (idx) {}, // TODO
                    ),
                  ),
                ),
                if (vm.isSaving)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}