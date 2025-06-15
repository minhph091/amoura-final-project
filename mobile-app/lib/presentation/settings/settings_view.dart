// lib/presentation/settings/settings_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/widgets/app_gradient_background.dart';
import 'block_list/block_list_view.dart';
import 'legal_resources/legal_resources_view.dart';
import 'settings_viewmodel.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_section_title.dart';
import 'widgets/settings_tile.dart';
import 'widgets/settings_divider.dart';
import 'widgets/settings_logout_button.dart';
import 'widgets/settings_version_text.dart';
import 'widgets/settings_theme_picker.dart';
import 'widgets/settings_language_selector.dart';
import 'theme/theme_mode_controller.dart';
import '../profile/view/profile_view.dart';
import '../profile/edit/edit_profile_view.dart';
import 'security/security_view.dart';
import 'notification_settings/notification_settings_view.dart';
import '../subscription/subscription_plans_view.dart';
import '../profile/view/profile_viewmodel.dart';
import '../../infrastructure/services/blocking_service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsViewModel>(
      create: (_) => SettingsViewModel(),
      child: AppGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Center(child: const Text('Settings')),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Consumer<ProfileViewModel>(
                builder: (context, profileVM, _) {
                  final profile = profileVM.profile;
                  return SettingsHeader(
                    avatarUrl: profile?['avatarUrl'] as String? ?? "",
                    firstName: profile?['firstName'] as String? ?? "",
                    lastName: profile?['lastName'] as String? ?? "",
                    username: profile?['username'] as String? ?? "",
                    isVip: false,
                  );
                },
              ),
              const SettingsDivider(),
              const SettingsSectionTitle(title: 'Account & Profile'),
              SettingsTile(
                icon: Icons.person_outline_rounded,
                title: 'View Profile',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProfileView(isMyProfile: true)),
                ),
              ),
              SettingsTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () {
                  final profile = context.read<ProfileViewModel>().profile;
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EditProfileView(profile: profile)),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.security_outlined,
                title: 'Account & Security',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SecurityView()),
                ),
              ),
              SettingsTile(
                icon: Icons.notifications_active_outlined,
                title: 'Notification Settings',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationSettingsView()),
                ),
              ),
              SettingsTile(
                icon: Icons.block_outlined,
                title: 'Block List',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => BlockingService(),
                      child: const BlockListView(),
                    ),
                  ),
                ),
              ),
              const SettingsDivider(),
              const SettingsSectionTitle(title: 'App Experience'),
              Consumer<ThemeModeController>(
                builder: (context, themeController, _) => SettingsThemePicker(
                  currentThemeMode: themeController.themeMode,
                  onChanged: (mode) => themeController.setThemeMode(mode),
                ),
              ),
              const SettingsLanguageSelector(), // Add language selector here
              SettingsTile(
                icon: Icons.subscriptions_outlined,
                title: 'Subscription Plans',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SubscriptionPlansView()),
                ),
              ),
              const SettingsDivider(),
              const SettingsSectionTitle(title: 'Support & Legal'),
              SettingsTile(
                icon: Icons.article_outlined,
                title: 'Legal & Resources',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LegalResourcesView()),
                ),
              ),
              const SizedBox(height: 16),
              const SettingsLogoutButton(),
              const SizedBox(height: 8),
              const SettingsVersionText(),
            ],
          ),
        ),
      ),
    );
  }
}