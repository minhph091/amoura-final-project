// lib/presentation/discovery/discovery_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/widgets/app_gradient_background.dart';
import 'widgets/action_buttons.dart';
import 'widgets/filter/filter_dialog.dart';
import 'widgets/swipe_card.dart';
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

          return AppGradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
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
                              Text(
                                'Amoura',
                                style: GoogleFonts.pacifico(
                                  fontSize: 28,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.filter_alt_outlined,
                                  size: 28,
                                  color: theme.colorScheme.primary,
                                ),
                                tooltip: 'Filter',
                                onPressed: () => showFilterDialog(context),
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