// lib/presentation/welcome/welcome_view.dart

import 'dart:async';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme/app_colors.dart';
import '../../core/constants/asset_path.dart';
import '../../app/routes/app_routes.dart';
import '../../config/language/app_localizations.dart';
import '../common/terms_of_service_view.dart';
import '../common/privacy_policy_view.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/language_selector.dart';
import 'widgets/welcome_slide_item.dart';
import 'widgets/welcome_page_indicator.dart';
import 'widgets/login_options_bottom_sheet.dart';

class WelcomeSlide {
  final String imagePath;
  final String title;
  final String subtitle;
  final Alignment imageAlignment;

  const WelcomeSlide({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.imageAlignment = Alignment.center,
  });
}

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _slideshowTimer;
  late AnimationController _mainContentAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideUpAnimation;

  List<WelcomeSlide> get _slides {
    final localizations = AppLocalizations.of(context);
    return [
      WelcomeSlide(
        imagePath: AssetPath.onboardingFindMatch,
        title: localizations.translate('welcome_slide1_title'),
        subtitle: localizations.translate('welcome_slide1_subtitle'),
      ),
      WelcomeSlide(
        imagePath: AssetPath.onboardingSafeSecure,
        title: localizations.translate('welcome_slide2_title'),
        subtitle: localizations.translate('welcome_slide2_subtitle'),
      ),
      WelcomeSlide(
        imagePath: AssetPath.onboardingStartChatting,
        title: localizations.translate('welcome_slide3_title'),
        subtitle: localizations.translate('welcome_slide3_subtitle'),
        imageAlignment: Alignment.bottomCenter,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _mainContentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _mainContentAnimationController,
      curve: Curves.easeInCubic,
    );
    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainContentAnimationController,
        curve: Curves.elasticOut.flipped,
      ),
    );
    _mainContentAnimationController.forward();
    _startSlideshow();
  }

  void _startSlideshow() {
    _slideshowTimer?.cancel();
    _slideshowTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _slides.length) nextPage = 0;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _mainContentAnimationController.dispose();
    _pageController.dispose();
    _slideshowTimer?.cancel();
    super.dispose();
  }

  void _showLoginOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (BuildContext bc) {
        return const LoginOptionsBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context);
    final slides = _slides; // Get localized slides

    const double buttonHeight = 56.0;
    final double desiredButtonWidth = screenWidth * 0.86;

    return Scaffold(
      body: Stack(
        children: [
          // SLIDESHOW
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final slide = slides[index];
                return WelcomeSlideItem(slide: slide, index: index);
              },
            ),
          ),
          // LOGO + TITLE
          Positioned(
            top: MediaQuery.of(context).padding.top + 25,
            left: 0,
            right: 0,
            child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AssetPath.logo,
                      height: 50,
                      color: AppColors.primary,
                      fit: BoxFit.contain,
                    ).animate().rotate(
                      delay: 700.ms,
                      duration: 800.ms,
                      curve: Curves.easeOutBack,
                      begin: -0.1,
                      end: 0.0,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Amoura',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(1, 2),
                          ),
                          Shadow(
                            blurRadius: 2,
                            color: AppColors.primary.withValues(alpha: 0.4),
                            offset: const Offset(-0.5, -0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 900.ms)
                .slideY(begin: -0.6, end: 0, curve: Curves.elasticOut.flipped),
          ),
          // Language selector in top-right corner
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: const LanguageSelector(isCompact: true),
          ),
          // BOTTOM CONTAINER
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.07,
                    28,
                    screenWidth * 0.07,
                    15,
                  ),
                  decoration: BoxDecoration(
                    color:
                        theme.brightness == Brightness.light
                            ? AppColors.surfaceLight.withValues(alpha: 0.6)
                            : colorScheme.surface.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (slides.length > 1)
                        WelcomePageIndicator(
                          currentPage: _currentPage,
                          slideCount: slides.length,
                        ),
                      SizedBox(height: slides.length > 1 ? 28 : 10),
                      SlideTransition(
                        position: _slideUpAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              AppButton(
                                text:
                                    localizations
                                        .translate('sign_in')
                                        .toUpperCase(),
                                onPressed:
                                    () => _showLoginOptionsBottomSheet(context),
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondary.withValues(alpha: 0.85),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                textColor: Colors.white,
                                height: buttonHeight,
                                width: desiredButtonWidth,
                                textStyle: textTheme.labelLarge?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.9,
                                ),
                                elevation: 7,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 20,
                                ),
                                loading: null,
                              ),
                              const SizedBox(height: 16),
                              AppButton(
                                text: localizations.translate(
                                  'create_new_account',
                                ),
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.register,
                                    ),
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    width: 1.6,
                                  ),
                                ),
                                textColor: Colors.white,
                                height: buttonHeight,
                                width: desiredButtonWidth,
                                textStyle: textTheme.labelLarge?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.9,
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom:
                              MediaQuery.of(context).padding.bottom > 0
                                  ? 0
                                  : 10.0,
                          left: 10,
                          right: 10,
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.75),
                              height: 1.45,
                              fontSize: 11.5,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: localizations.translate(
                                  'terms_agreement_text',
                                ),
                              ),
                              TextSpan(
                                text: localizations.translate(
                                  'terms_service_link',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFD81B60), // Darker pink color
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap =
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      const TermsOfServiceView(),
                                            ),
                                          ),
                              ),
                              TextSpan(
                                text: localizations.translate('and_text'),
                              ),
                              TextSpan(
                                text: localizations.translate(
                                  'privacy_policy_link',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFD81B60), // Darker pink color
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap =
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      const PrivacyPolicyView(),
                                            ),
                                          ),
                              ),
                              TextSpan(
                                text: AppLocalizations.of(
                                  context,
                                ).translate('dot'),
                              ), // key 'dot' = '.'
                            ],
                          ),
                        ).animate(delay: 500.ms).fadeIn(duration: 600.ms),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).padding.bottom > 0 ? 8 : 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
