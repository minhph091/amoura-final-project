// lib/presentation/main_navigator/main_navigator_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main_navigator_viewmodel.dart';
import 'widgets/nav_bar_item.dart';
import '../discovery/discovery_view.dart';

class MainNavigatorView extends StatelessWidget {
  const MainNavigatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainNavigatorViewModel(),
      child: Consumer<MainNavigatorViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            body: IndexedStack(
              index: vm.currentIndex,
              children: const [
                DiscoveryView(),
                Placeholder(), // Matches screen
                Placeholder(), // Chat screen
                Placeholder(), // Settings screen
              ],
            ),
            bottomNavigationBar: BottomAppBar(
              elevation: 15,
              color: Theme.of(context).colorScheme.surface,
              child: SizedBox(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    NavBarItem(
                      icon: Icons.explore,
                      label: "Discover",
                      isActive: vm.currentIndex == 0,
                      onTap: () => vm.setCurrentIndex(0),
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.cyan],
                      ),
                    ),
                    NavBarItem(
                      icon: Icons.favorite,
                      label: "Matches",
                      isActive: vm.currentIndex == 1,
                      onTap: () => vm.setCurrentIndex(1),
                      badge: "VIP",
                      gradient: const LinearGradient(
                        colors: [Colors.pink, Colors.red],
                      ),
                    ),
                    NavBarItem(
                      icon: Icons.chat,
                      label: "Chat",
                      isActive: vm.currentIndex == 2,
                      onTap: () => vm.setCurrentIndex(2),
                      badgeCount: vm.chatBadgeCount,
                      gradient: const LinearGradient(
                        colors: [Colors.green, Colors.lime],
                      ),
                    ),
                    NavBarItem(
                      icon: Icons.settings,
                      label: "Settings",
                      isActive: vm.currentIndex == 3,
                      onTap: () => vm.setCurrentIndex(3),
                      badgeCount: vm.notificationBadgeCount,
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.orange],
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