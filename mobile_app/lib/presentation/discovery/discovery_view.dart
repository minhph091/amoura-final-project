// lib/presentation/discovery/discovery_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/language/app_localizations.dart';
import '../shared/widgets/app_gradient_background.dart';
import 'discovery_viewmodel.dart';
import 'widgets/simple_swipeable_card.dart';
import 'widgets/discovery_header.dart';

class DiscoveryView extends StatefulWidget {
  const DiscoveryView({super.key});

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> with TickerProviderStateMixin {
  late DiscoveryViewModel _viewModel;
  late AnimationController _buttonAnimationController;
  bool _isLikeHighlighted = false;
  bool _isPassHighlighted = false;
  double _currentSwipeOffset = 0.0; // Track swipe progress

  @override
  void initState() {
    super.initState();
    _viewModel = DiscoveryViewModel();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Initialize discovery data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set context for match dialog
      _viewModel.setContext(context);
      _viewModel.initialize();
    });
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: ChangeNotifierProvider<DiscoveryViewModel>.value(
          value: _viewModel,
          child: Consumer<DiscoveryViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                children: [
                  // Header with logo and filters
                  const DiscoveryHeader(),
                  
                  // Main content area - full size profile cards
                  Expanded(
                    child: Stack(
                      children: [
                        // Full size cards area
                        _buildCardsArea(viewModel),
                        
                        // Beautiful action buttons - đè lên profile như ảnh mẫu
                        Positioned(
                          bottom: 20, // Giảm về 20 để buttons đè lên profile
                          left: 0,
                          right: 0,
                          child: _buildBeautifulActionButtons(viewModel),
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
                    ),
                  ),
                ],
              );
            },
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

    // Full size profile card - kéo xuống chiếm 1/2 buttons
    return MediaQuery.removePadding(
      context: context,
      removeLeft: true,
      removeRight: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 45), // Giảm từ 90 xuống 45 để chiếm 1/2 buttons
        child: SimpleSwipeableCard(
          key: ValueKey('swipe_${viewModel.currentProfile!.userId}_${viewModel.nextProfile?.userId ?? 'none'}'),
          currentProfile: viewModel.currentProfile!,
          currentInterests: viewModel.getCurrentInterests(),
          currentDistance: viewModel.getCurrentDistance(),
          currentCommonInterests: viewModel.getCurrentCommonInterests(),
          nextProfile: viewModel.nextProfile,
          nextInterests: viewModel.getNextInterests(),
          nextDistance: viewModel.getNextDistance(),
          nextCommonInterests: viewModel.getNextCommonInterests(),
          onSwipeDirection: _onSwipeDirection, // Add callback for button highlighting
          onSwipeProgress: _onSwipeProgress, // Track swipe progress
          onSwipeReset: _onSwipeReset, // Reset when swipe is cancelled
          onSwipeCompleted: (isLike) {
            if (isLike) {
              viewModel.likeCurrentProfile();
            } else {
              viewModel.passCurrentProfile();
            }
          },
        ),
      ),
    );
  }
  
  void _onSwipeDirection(bool isLike) {
    // Chỉ set highlight, không tự động reset
    if (mounted) {
      setState(() {
        if (isLike) {
          _isLikeHighlighted = true;
          _isPassHighlighted = false;
        } else {
          _isLikeHighlighted = false;
          _isPassHighlighted = true;
        }
      });
    }
  }
  
  void _onSwipeProgress(double offset) {
    // Update swipe progress for smooth highlighting
    if (mounted) {
      setState(() {
        _currentSwipeOffset = offset;
        if (offset.abs() > 50) { // Threshold để bắt đầu highlight
          if (offset > 0) {
            _isLikeHighlighted = true;
            _isPassHighlighted = false;
          } else {
            _isLikeHighlighted = false;
            _isPassHighlighted = true;
          }
        } else {
          _isLikeHighlighted = false;
          _isPassHighlighted = false;
        }
      });
    }
  }
  
  void _onSwipeReset() {
    // Reset highlights when swipe is cancelled
    if (mounted) {
      setState(() {
        _isLikeHighlighted = false;
        _isPassHighlighted = false;
        _currentSwipeOffset = 0.0;
      });
    }
  }
  
  Widget _buildBeautifulActionButtons(DiscoveryViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), // Giảm padding để card full width hơn
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Rewind button
          _buildAnimatedActionButton(
            onTap: () {
              _viewModel.rewindToPreviousProfile();
            },
            icon: Icons.refresh,
            backgroundColor: Colors.yellow[600]!,
            size: 50,
          ),
          
          // Pass/Dislike button
          _buildAnimatedActionButton(
            onTap: () => viewModel.passCurrentProfile(),
            icon: Icons.close,
            backgroundColor: Colors.red[500]!,
            size: 60,
            isHighlighted: _isPassHighlighted, // Add highlighting
          ),
          
          // Like button
          _buildAnimatedActionButton(
            onTap: () => viewModel.likeCurrentProfile(),
            icon: Icons.favorite,
            backgroundColor: Colors.pink[500]!,
            size: 60,
            isHighlighted: _isLikeHighlighted, // Add highlighting
          ),
          
          // Star/Super like button
          _buildAnimatedActionButton(
            onTap: () {
              // TODO: Implement super like logic
              print('Super like tapped');
            },
            icon: Icons.star,
            backgroundColor: Colors.blue[500]!,
            size: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color backgroundColor,
    required double size,
    bool isHighlighted = false, // Add highlighting parameter
  }) {
    final highlightedSize = size * 1.7; // Scale 1.7 khi highlighted
    final currentSize = isHighlighted ? highlightedSize : size;
    final Color baseBg = Colors.white; // white background as requested
    final Color iconColor = backgroundColor; // keep icon color
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) {
          // Scale down effect on press
        },
        onTapUp: (_) {
          onTap();
        },
        onTapCancel: () {
          // Reset scale if tap is cancelled
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: currentSize,
          height: currentSize,
          decoration: BoxDecoration(
            color: isHighlighted ? iconColor : baseBg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isHighlighted ? iconColor : baseBg).withOpacity(isHighlighted ? 0.35 : 0.12),
                blurRadius: isHighlighted ? 20 : 12, // Blur lớn hơn khi highlighted
                offset: const Offset(0, 4),
                spreadRadius: isHighlighted ? 4 : 0, // Spread khi highlighted
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: isHighlighted ? Colors.white : iconColor,
            size: currentSize * 0.4, // Sử dụng currentSize để icon cũng scale theo
          ),
        ),
      ),
    );
  }
}
