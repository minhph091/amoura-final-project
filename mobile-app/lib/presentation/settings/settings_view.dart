// lib/presentation/settings/settings_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/widgets/app_gradient_background.dart';

import 'legal_resources/legal_resources_view.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_section_title.dart';
import 'widgets/settings_tile.dart';
import 'widgets/settings_divider.dart';
import 'widgets/settings_logout_button.dart';
import 'widgets/settings_version_text.dart';
import 'widgets/settings_theme_picker.dart';
import 'theme/theme_mode_controller.dart';

import '../profile/view/profile_view.dart';
import '../profile/edit/edit_profile_view.dart';
import 'security/security_view.dart';
import 'notification_settings/notification_settings_view.dart';
import 'subscription/plan_list/plan_list_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user từ Provider/ViewModel sau này
    final avatarUrl = "";
    final firstName = "";
    final lastName = "";
    final username = "";
    final isVip = false;

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            SettingsHeader(
              avatarUrl: avatarUrl,
              firstName: firstName,
              lastName: lastName,
              username: username,
              isVip: isVip,
            ),
            const SettingsDivider(),
            const SettingsSectionTitle(title: 'Account & Profile'),
            SettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'View Profile',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileView(profile: null, isMyProfile: true))),            ),
            SettingsTile(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileView(profile: null))),            ),
            SettingsTile(
              icon: Icons.security_outlined,
              title: 'Account & Security',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SecurityView())),
            ),
            SettingsTile(
              icon: Icons.notifications_active_outlined,
              title: 'Notification Settings',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationSettingsView())),
            ),
            const SettingsDivider(),
            const SettingsSectionTitle(title: 'App Experience'),
            Consumer<ThemeModeController>(
              builder: (context, themeController, _) => SettingsThemePicker(
                currentThemeMode: themeController.themeMode,
                onChanged: (mode) => themeController.setThemeMode(mode),
              ),
            ),
            SettingsTile(
              icon: Icons.subscriptions_outlined,
              title: 'Subscription Plans',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const planListView())),
            ),
            const SettingsDivider(),
            const SettingsSectionTitle(title: 'Support & Legal'),
            SettingsTile(
              icon: Icons.article_outlined,
              title: 'Legal & Resources',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LegalResourcesView())),
            ),
            const SizedBox(height: 16),
            const SettingsLogoutButton(),
            const SizedBox(height: 8),
            const SettingsVersionText(),
          ],
        ),
      ),
    );
  }
}