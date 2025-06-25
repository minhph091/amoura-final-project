// lib/presentation/profile/edit/edit_profile_view.dart
import 'package:amoura/presentation/profile/edit/sections/edit_profile_bio_photos_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider để sử dụng Provider.of
import '../../shared/dialogs/confirm_dialog.dart';
import '../../shared/widgets/app_gradient_background.dart';
import '../setup/theme/setup_profile_theme.dart';
import 'edit_profile_viewmodel.dart';
import 'sections/edit_profile_avatar_cover_section.dart';
import 'sections/edit_profile_basic_info_section.dart';
import 'sections/edit_profile_location_section.dart';
import 'sections/edit_profile_appearance_section.dart';
import 'sections/edit_profile_job_education_section.dart';
import 'sections/edit_profile_lifestyle_section.dart';
import 'sections/edit_profile_interests_languages_section.dart';
import 'widgets/collapsible_edit_section.dart';
import '../view/profile_viewmodel.dart'; // Import ProfileViewModel để truy cập dữ liệu profile

class EditProfileView extends StatefulWidget {
  final dynamic profile;

  const EditProfileView({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late EditProfileViewModel _viewModel;
  bool _isLoading = false;
  String? _expandedSection;

  @override
  void initState() {
    super.initState();
    // Initialize view model with the provided profile or fetch from ProfileViewModel if null
    // Comment: This line retrieves the current profile data from ProfileViewModel if widget.profile is not provided
    final profileData = widget.profile ?? Provider.of<ProfileViewModel>(context, listen: false).profile;
    _viewModel = EditProfileViewModel(profile: profileData);
    // No section is expanded initially
    _expandedSection = null;

    // Comment: Load profile data if not provided
    if (profileData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ProfileViewModel>(context, listen: false).loadProfile().then((_) {
          if (mounted) {
            setState(() {
              _viewModel = EditProfileViewModel(profile: Provider.of<ProfileViewModel>(context, listen: false).profile);
            });
          }
        });
      });
    }
  }

  void _toggleSection(String sectionKey) {
    setState(() {
      if (_expandedSection == sectionKey) {
        _expandedSection = null; // Close if already open
      } else {
        _expandedSection = sectionKey; // Open this section and close others
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fix the errors before saving")),
      );
      return;
    }

    _formKey.currentState!.save();

    final shouldSave = await showConfirmDialog(
      context: context,
      title: 'Save Changes',
      content: 'Do you want to save all changes to your profile?',
      confirmText: 'Save',
      cancelText: 'Cancel',
      icon: Icons.save,
      iconColor: ProfileTheme.darkPink,
      onConfirm: () async {},
    );

    if (shouldSave == true) {
      setState(() => _isLoading = true);

      try {
        await _viewModel.saveProfile(); // API call to update profile data

        if (mounted) {
          // Reload lại profile khi quay về Settings
          final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
          await profileVM.loadProfile();

          // Xóa cache hình ảnh cho avatar và cover
          if (_viewModel.avatarUrl != null) {
            imageCache.evict(NetworkImage(_viewModel.avatarUrl!));
          }
          if (_viewModel.coverUrl != null) {
            imageCache.evict(NetworkImage(_viewModel.coverUrl!));
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully"),
              backgroundColor: Colors.green,
            ),
          );

          // Pop back to previous screen
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to update profile: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_viewModel.hasChanges) {
      final shouldDiscard = await showConfirmDialog(
        context: context,
        title: 'Discard Changes',
        content: 'You have unsaved changes. Are you sure you want to discard them?',
        confirmText: 'Discard',
        cancelText: 'Keep Editing',
        icon: Icons.warning,
        iconColor: Colors.orange,
        onConfirm: () async {},
      );

      if (shouldDiscard == true) {
        _viewModel.resetToOriginal();
        return true;
      }
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: AppGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Edit Profile', style: TextStyle(
              color: ProfileTheme.darkPurple,
              fontWeight: FontWeight.bold,
            )),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ProfileTheme.darkPurple),
              onPressed: () async {
                if (await _onWillPop()) {
                  Navigator.pop(context);
                }
              },
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.save, color: ProfileTheme.darkPink),
                tooltip: 'Save Changes',
                onPressed: _isLoading ? null : _saveProfile,
              ),
            ],
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator(color: ProfileTheme.darkPink))
              : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // Avatar and Cover Photo Section (Always visible)
                EditProfileAvatarCoverSection(viewModel: _viewModel),

                const SizedBox(height: 16),

                // Basic Info Section (Steps 1, 2, 3)
                CollapsibleEditSection(
                  title: "Basic Information",
                  icon: Icons.person,
                  isExpanded: _expandedSection == 'basic',
                  onToggle: () => _toggleSection('basic'),
                  child: EditProfileBasicInfoSection(viewModel: _viewModel),
                ),

                const SizedBox(height: 10),

                // Bio & Photos Section (Step 10)
                CollapsibleEditSection(
                  title: "Bio & Photos",
                  icon: Icons.photo_library,
                  isExpanded: _expandedSection == 'bio',
                  onToggle: () => _toggleSection('bio'),
                  child: EditProfileBioPhotosSection(viewModel: _viewModel),
                ),

                const SizedBox(height: 10),

                // Location Section (Step 5)
                CollapsibleEditSection(
                  title: "Location",
                  icon: Icons.location_on,
                  isExpanded: _expandedSection == 'location',
                  onToggle: () => _toggleSection('location'),
                  child: EditProfileLocationSection(viewModel: _viewModel),
                ),

                const SizedBox(height: 10),

                // Appearance Section (Step 6)
                CollapsibleEditSection(
                  title: "Appearance",
                  icon: Icons.accessibility_new,
                  isExpanded: _expandedSection == 'appearance',
                  onToggle: () => _toggleSection('appearance'),
                  child: EditProfileAppearanceSection(viewModel: _viewModel),
                ),

                const SizedBox(height: 10),

                // Job & Education Section (Step 7)
                CollapsibleEditSection(
                  title: "Job & Education",
                  icon: Icons.work,
                  isExpanded: _expandedSection == 'job',
                  onToggle: () => _toggleSection('job'),
                  child: EditProfileJobEducationSection(viewModel: _viewModel),
                ),

                const SizedBox(height: 10),

                // Lifestyle Section (Step 8)
                CollapsibleEditSection(
                  title: "Lifestyle",
                  icon: Icons.emoji_emotions,
                  isExpanded: _expandedSection == 'lifestyle',
                  onToggle: () => _toggleSection('lifestyle'),
                  child: EditProfileLifestyleSection(viewModel: _viewModel),
                ),

                const SizedBox(height: 10),

                // Interests & Languages Section (Step 9)
                CollapsibleEditSection(
                  title: "Interests & Languages",
                  icon: Icons.interests,
                  isExpanded: _expandedSection == 'interests',
                  onToggle: () => _toggleSection('interests'),
                  child: EditProfileInterestsLanguagesSection(viewModel: _viewModel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}