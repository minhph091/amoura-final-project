// lib/presentation/discovery/discovery_view.dart
import 'package:amoura/presentation/discovery/widgets/action_buttons.dart';
import 'package:amoura/presentation/discovery/widgets/filter_dialog.dart';
import 'package:amoura/presentation/discovery/widgets/swipe_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'discovery_viewmodel.dart';

class DiscoveryView extends StatelessWidget {
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (_) => DiscoveryViewModel(),
      child: Consumer<DiscoveryViewModel>(
        builder: (context, vm, _) {
          final profiles = vm.profiles;
          final interests = vm.interests;

          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.brightness == Brightness.light
                        ? const Color(0xFFF5F6FA)
                        : const Color(0xFF121212),
                    theme.brightness == Brightness.light
                        ? const Color(0xFFEFF3FF)
                        : const Color(0xFF1E1E1E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.filter_alt_outlined,
                                  size: 28,
                                  color: theme.colorScheme.primary,
                                ),
                                tooltip: 'Filter',
                                onPressed: () => showFilterDialog(context),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.notifications_sharp,
                                  size: 28,
                                  color: theme.colorScheme.secondary,
                                ),
                                tooltip: 'Notifications',
                                onPressed: () {}, // Logic to be implemented
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: profiles.isNotEmpty
                                ? SwipeCardStack(
                                    profile: profiles.first,
                                    interests: interests,
                                  )
                                : const Center(child: Text('No profiles available')),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: ActionButtonsRow(),
                        ),
                        SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
                      ],
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