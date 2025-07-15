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
import '../../core/services/profile_service.dart';
import 'discovery_recommendation_cache.dart';
import '../../infrastructure/services/app_initialization_service.dart';
import '../../infrastructure/services/image_precache_service.dart';
import '../../infrastructure/services/app_startup_service.dart';

class DiscoveryView extends StatefulWidget {
  const DiscoveryView({super.key});

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  late DiscoveryViewModel _viewModel;
  bool _highlightLike = false;
  bool _highlightPass = false;

  @override
  void initState() {
    super.initState();
    _viewModel = DiscoveryViewModel(
      rewindService: getIt<RewindService>(),
      matchService: getIt<MatchService>(),
      profileService: getIt<ProfileService>(),
    );
    
    // Load recommendations when screen is created
    _viewModel.loadRecommendations();
    
    // Chỉ precache thêm nếu dữ liệu chưa được chuẩn bị từ AppStartupService
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!AppStartupService.instance.isReady) {
        final recs = _viewModel.recommendations;
        if (recs.isNotEmpty && mounted) {
          print('DiscoveryView: Precache thêm ảnh vì dữ liệu chưa được chuẩn bị từ đầu');
          try {
            await ImagePrecacheService.instance.precacheMultipleProfiles(recs, context, count: 5);
          } catch (e) {
            print('DiscoveryView: Lỗi khi precache: $e');
          }
        }
      } else {
        print('DiscoveryView: Dữ liệu đã được chuẩn bị từ AppStartupService, không cần precache thêm');
      }
    });
  }

  void _setHighlightLike(bool value) {
    setState(() {
      _highlightLike = value;
    });
  }
  void _setHighlightPass(bool value) {
    setState(() {
      _highlightPass = value;
    });
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
                child: Column(
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
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: _buildContent(context, vm),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: ActionButtonsRow(
                                highlightLike: _highlightLike,
                                highlightPass: _highlightPass,
                              ),
                            ),
                          ),
                        ],
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No more profiles'),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => vm.loadRecommendations(forceRefresh: true),
              child: const Text('Reload Data'),
            ),
          ],
        ),
      );
    }

    return SwipeCardStack(
      profile: currentProfile,
      interests: vm.interests,
      onHighlightLike: _setHighlightLike,
      onHighlightPass: _setHighlightPass,
    );
  }
}