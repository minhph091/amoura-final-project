// lib/presentation/discovery/discovery_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/language/app_localizations.dart';
import '../shared/widgets/app_gradient_background.dart';
import 'discovery_viewmodel.dart';
import 'widgets/simple_swipeable_card.dart';
import 'widgets/action_buttons.dart';

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
    _viewModel = DiscoveryViewModel();
    
    // Initialize discovery data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initialize();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: ChangeNotifierProvider<DiscoveryViewModel>.value(
            value: _viewModel,
            child: Consumer<DiscoveryViewModel>(
              builder: (context, viewModel, child) {
                return Stack(
                  children: [
                    // Main content
                    Column(
                      children: [
                        // Cards area
                        Expanded(
                          child: _buildCardsArea(viewModel),
                        ),
                        
                        // Action buttons
                        const SizedBox(height: 16),
                        const ActionButtons(),
                        const SizedBox(height: 32),
                      ],
                    ),
                    
                    // Loading overlay
                    if (viewModel.isLoading && !viewModel.hasProfiles)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardsArea(DiscoveryViewModel viewModel) {
    if (!viewModel.hasProfiles) {
      if (viewModel.isLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.favorite_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).translate('no_more_profiles'),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.refresh(),
                child: Text(AppLocalizations.of(context).translate('refresh')),
              ),
            ],
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SimpleSwipeableCard(
        currentProfile: viewModel.currentProfile!,
        currentInterests: viewModel.getCurrentInterests(),
        currentDistance: viewModel.getCurrentDistance(),
        nextProfile: viewModel.nextProfile,
        nextInterests: viewModel.getNextInterests(),
        nextDistance: viewModel.getNextDistance(),
        onSwiped: viewModel.onSwipeComplete,
      ),
    );
  }
}
