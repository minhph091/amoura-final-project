import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_navigator_viewmodel.dart';
import 'widgets/nav_bar_item.dart';
import '../discovery/discovery_view.dart';
import '../settings/settings_view.dart';

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
              children: [
                const DiscoveryView(), // Discovery screen
                const Placeholder(), // Placeholder for Favorites
                const Placeholder(), // Placeholder for Chats
                const Placeholder(), // Placeholder for Notifications
                const SettingsView(), // Settings screen
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
                    Expanded(
                      child: NavBarItem(
                        icon: Icons.explore,
                        isActive: vm.currentIndex == 0,
                        onTap: () => vm.setCurrentIndex(0),
                        activeColor: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: NavBarItem(
                        icon: Icons.favorite,
                        isActive: vm.currentIndex == 1,
                        onTap: () => vm.setCurrentIndex(1),
                        badge: "VIP",
                        activeColor: Colors.pink,
                      ),
                    ),
                    Expanded(
                      child: NavBarItem(
                        icon: Icons.chat,
                        isActive: vm.currentIndex == 2,
                        onTap: () => vm.setCurrentIndex(2),
                        badgeCount: vm.chatBadgeCount,
                        activeColor: Colors.green,
                      ),
                    ),
                    Expanded(
                      child: NavBarItem(
                        icon: Icons.notifications,
                        isActive: vm.currentIndex == 3,
                        onTap: () => vm.setCurrentIndex(3),
                        badgeCount: vm.notificationBadgeCount,
                        activeColor: Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: NavBarItem(
                        icon: Icons.settings,
                        isActive: vm.currentIndex == 4,
                        onTap: () => vm.setCurrentIndex(4),
                        activeColor: Colors.purple,
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