import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/language/app_localizations.dart';
import 'main_navigator_viewmodel.dart';
import 'widgets/nav_bar_item.dart';
import 'widgets/animated_gradient_background.dart';
import '../discovery/discovery_view.dart';
import '../match/liked_users/liked_users_view.dart';
import '../chat/chat_list/chat_list_view.dart';
import '../notification/notification_view.dart';
import '../settings/settings_view.dart';

class MainNavigatorView extends StatelessWidget {
  const MainNavigatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ChangeNotifierProvider(
      create: (_) => MainNavigatorViewModel(),
      child: Consumer<MainNavigatorViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            body: IndexedStack(
              index: vm.currentIndex,
              children: [
                const DiscoveryView(),
                const LikedUsersView(),
                const ChatListView(),
                const NotificationView(),
                const SettingsView(),
              ],
            ),
            bottomNavigationBar: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 30), // Bỏ margin trái/phải để discovery full width
              height: 90,
              child: AnimatedGradientBackground(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: NavBarItem(
                        customIconPath: 'assets/icons/discover_icon.svg',
                        label: localizations.translate('explore'),
                        isActive: vm.currentIndex == 0,
                        onTap: () => vm.setCurrentIndex(0),
                        activeColor: const Color(0xFF6C63FF),
                      ),
                    ),
                    Expanded(
                      child: NavBarItem(
                        customIconPath: 'assets/icons/likes_icon.svg',
                        label: localizations.translate('likes'),
                        isActive: vm.currentIndex == 1,
                        onTap: () => vm.setCurrentIndex(1),
                        badge: "VIP",
                        activeColor: const Color(0xFFFF6B9D),
                      ),
                    ),
                    Expanded(
                      child: NavBarItem(
                        customIconPath: 'assets/icons/chat_icon.svg',
                        label: localizations.translate('chat'),
                        isActive: vm.currentIndex == 2,
                        onTap: () => vm.setCurrentIndex(2),
                        badgeCount: vm.chatBadgeCount,
                        activeColor: const Color(0xFF4ECDC4),
                      ),
                    ),
                    Expanded(
                      child: NavBarItem(
                        customIconPath: 'assets/icons/notification_icon.svg',
                        label: localizations.translate('notifications'),
                        isActive: vm.currentIndex == 3,
                        onTap: () => vm.setCurrentIndex(3),
                        badgeCount: vm.notificationBadgeCount,
                        activeColor: const Color(0xFFFFB347),
                      ),
                    ),
                    Expanded(
                      child: NavBarItem(
                        customIconPath: 'assets/icons/settings_icon.svg',
                        label: localizations.translate('settings'),
                        isActive: vm.currentIndex == 4,
                        onTap: () => vm.setCurrentIndex(4),
                        activeColor: const Color(0xFF9B59B6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
