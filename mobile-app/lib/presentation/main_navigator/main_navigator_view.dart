// lib/presentation/main_navigator/main_navigator_view.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../discovery/discovery_view.dart';
import 'main_navigator_viewmodel.dart';
import 'widgets/gradient_icon.dart';
import 'widgets/nav_icon_with_badge.dart';

class MainNavigatorView extends StatelessWidget {
  const MainNavigatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ChangeNotifierProvider(
      create: (_) => MainNavigatorViewModel(),
      child: Consumer<MainNavigatorViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Amoura",
                style: theme.textTheme.displayMedium?.copyWith(
                  fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.person, color: colorScheme.primary),
                  onPressed: () {
                    // TODO: Navigate to Profile screen
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: colorScheme.primary),
                  onPressed: () {
                    // TODO: Navigate to Settings screen
                  },
                ),
              ],
              backgroundColor: colorScheme.surface,
              elevation: 0,
            ),
            body: IndexedStack(
              index: vm.currentIndex,
              children: const [
                DiscoverView(), // Tab Discovery (mặc định)
                // TODO: Thêm các tab khác (Chat, Notification, Profile, v.v.) sau
                Placeholder(),
                Placeholder(),
                Placeholder(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: vm.currentIndex,
              onTap: (index) => vm.setCurrentIndex(index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
              backgroundColor: colorScheme.surface,
              selectedLabelStyle: TextStyle(
                fontFamily: GoogleFonts.lato().fontFamily,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: GoogleFonts.lato().fontFamily,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: NavIconWithBadge(
                    icon: GradientIcon(
                      icon: Icons.explore,
                      size: 28,
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ),
                    ),
                    isActive: vm.currentIndex == 0,
                  ),
                  label: "Discover",
                ),
                BottomNavigationBarItem(
                  icon: NavIconWithBadge(
                    icon: GradientIcon(
                      icon: Icons.favorite,
                      size: 28,
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ),
                    ),
                    isActive: vm.currentIndex == 1,
                  ),
                  label: "Matches",
                ),
                BottomNavigationBarItem(
                  icon: NavIconWithBadge(
                    icon: GradientIcon(
                      icon: Icons.chat,
                      size: 28,
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ),
                    ),
                    isActive: vm.currentIndex == 2,
                    badgeCount: vm.chatBadgeCount,
                  ),
                  label: "Chat",
                ),
                BottomNavigationBarItem(
                  icon: NavIconWithBadge(
                    icon: GradientIcon(
                      icon: Icons.notifications,
                      size: 28,
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ),
                    ),
                    isActive: vm.currentIndex == 3,
                    badgeCount: vm.notificationBadgeCount,
                    vipBadge: vm.vipBadge,
                  ),
                  label: "Notifications",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}