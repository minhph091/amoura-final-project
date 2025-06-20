// lib/presentation/discovery/discovery_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/di/injection.dart';
import '../shared/widgets/app_gradient_background.dart';
import 'widgets/action_buttons.dart';
import 'widgets/filter/filter_dialog.dart';
import 'widgets/swipe_card.dart';
import 'discovery_viewmodel.dart';
import '../../infrastructure/services/subscription_service.dart';
import '../../infrastructure/services/rewind_service.dart';
import '../../core/services/match_service.dart';

class DiscoveryView extends StatefulWidget {
  const DiscoveryView({super.key});

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  late DiscoveryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DiscoveryViewModel(
      rewindService: getIt<RewindService>(),
      matchService: getIt<MatchService>(),
    );
    // Load recommendations when screen is created
    _viewModel.loadRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _viewModel),
        ChangeNotifierProvider.value(value: getIt<SubscriptionService>()),
        ChangeNotifierProvider.value(value: getIt<RewindService>()),
      ],
      child: Consumer<DiscoveryViewModel>(
        builder: (context, vm, _) {
          // Set context for ViewModel to show dialogs
          vm.setContext(context);

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
                            child: _buildContent(context, vm),
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

  Widget _buildContent(BuildContext context, DiscoveryViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${vm.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.loadRecommendations(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (vm.recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No profiles available'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.loadRecommendations(),
              child: const Text('Load Recommendations'),
            ),
          ],
        ),
      );
    }

    final currentProfile = vm.currentProfile;
    if (currentProfile == null) {
      return const Center(child: Text('No more profiles'));
    }

    return SwipeCardStack(
      profile: currentProfile,
      interests: vm.interests,
    );
  }
}