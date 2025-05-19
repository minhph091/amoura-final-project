// lib/presentation/welcome/welcome_view.dart

import 'dart:async';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme/app_colors.dart';
import '../../app/routes/app_routes.dart';
import '../common/terms_of_service_view.dart';
import '../common/privacy_policy_view.dart';
import '../shared/widgets/app_button.dart';

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

class _WelcomeViewState extends State<WelcomeView> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _slideshowTimer;
  late AnimationController _mainContentAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideUpAnimation;

  final List<WelcomeSlide> _slides = const [
    WelcomeSlide(
      imagePath: 'assets/images/welcome_find_your_match.png',
      title: 'Explore a World of Connections',
      subtitle: 'Find new friends, meaningful relationships, and more.',
    ),
    WelcomeSlide(
      imagePath: 'assets/images/welcome_safe_secure.png',
      title: 'Showcase Your Personality',
      subtitle: 'Create a unique profile, share your story and interests.',
    ),
    WelcomeSlide(
      imagePath: 'assets/images/welcome_start_chatting.png',
      title: 'Start Your Journey of Love',
      subtitle: 'Amoura - Where genuine connections are built and love flourishes.',
      imageAlignment: Alignment.bottomCenter,
    ),
  ];

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
    ).animate(CurvedAnimation(
      parent: _mainContentAnimationController,
      curve: Curves.elasticOut.flipped,
    ));
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final List<Map<String, dynamic>> loginMethods = [
      {
        'label': 'Email/Phone',
        'icon': FontAwesomeIcons.solidEnvelope,
        'color': AppColors.primary,
        'route': AppRoutes.login,
      },
      {
        'label': 'OTP Verification',
        'icon': FontAwesomeIcons.phoneFlip,
        'color': AppColors.secondary,
        'route': AppRoutes.loginWithEmailOtp,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (BuildContext bc) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              18,
              20,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.97)
                  : colorScheme.surface.withValues(alpha: 0.97),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: -12,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 55,
                    height: 5.5,
                    margin: const EdgeInsets.only(bottom: 22),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Text(
                  'Sign In With',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: 0.25,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: loginMethods.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> method = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                if (method['route'] != null) {
                                  Navigator.pushNamed(context, method['route'] as String);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Login with ${method['label']} coming soon!')),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(40),
                              splashColor: (method['color'] as Color).withValues(alpha: 0.25),
                              highlightColor: (method['color'] as Color).withValues(alpha: 0.15),
                              child: Container(
                                width: 75,
                                height: 75,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (method['color'] as Color).withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: (method['color'] as Color).withValues(alpha: 0.6),
                                    width: 1.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (method['color'] as Color).withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      spreadRadius: 1.5,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: FaIcon(
                                    method['icon'] as IconData,
                                    color: method['color'] as Color,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              method['label'] as String,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(delay: (150 * index).ms, duration: 450.ms)
                            .slideY(begin: 0.5, curve: Curves.easeOutExpo)
                            .scaleXY(begin: 0.8, duration: 300.ms, curve: Curves.easeOutBack),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text(
                    'CANCEL',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    const double buttonHeight = 56.0;
    final double desiredButtonWidth = screenWidth * 0.86;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      slide.imagePath,
                      fit: BoxFit.cover,
                      alignment: slide.imageAlignment,
                      key: ValueKey<String>(slide.imagePath),
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade900,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white.withValues(alpha: 0.3),
                              size: 60,
                            ),
                          ),
                        );
                      },
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                        .scale(begin: const Offset(1.05, 1.05), duration: 1200.ms, curve: Curves.easeOutQuart),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.35),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: screenHeight * 0.38,
                      left: 30,
                      right: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: [
                                const Shadow(
                                  blurRadius: 10,
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                )
                              ],
                            ),
                          )
                              .animate(key: ValueKey<String>("title_ws_$index"))
                              .fadeIn(delay: 300.ms, duration: 600.ms)
                              .slideX(begin: -0.3, duration: 600.ms, curve: Curves.easeOutExpo),
                          const SizedBox(height: 12),
                          Text(
                            slide.subtitle,
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.5,
                              letterSpacing: 0.2,
                              shadows: const [
                                Shadow(blurRadius: 5, color: Colors.black45),
                              ],
                            ),
                          )
                              .animate(key: ValueKey<String>("subtitle_ws_$index"))
                              .fadeIn(delay: 450.ms, duration: 600.ms)
                              .slideX(begin: -0.3, duration: 600.ms, curve: Curves.easeOutExpo),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 25,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/light_amoura.png',
                  height: 50,
                  color: AppColors.primary,
                  fit: BoxFit.contain,
                ).animate().rotate(delay: 700.ms, duration: 800.ms, curve: Curves.easeOutBack, begin: -0.1, end: 0.0),
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
            ).animate().fadeIn(duration: 900.ms).slideY(begin: -0.6, end: 0, curve: Curves.elasticOut.flipped),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.07, 28, screenWidth * 0.07, 15),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.light
                        ? AppColors.surfaceLight.withValues(alpha: 0.6)
                        : colorScheme.surface.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                      if (_slides.length > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_slides.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOutCubic,
                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                              height: 8.5,
                              width: _currentPage == index ? 26.0 : 8.5,
                              decoration: BoxDecoration(
                                color:
                                _currentPage == index ? AppColors.secondary : Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          }).animate(interval: 60.ms).fadeIn(duration: 300.ms),
                        ),
                      SizedBox(height: _slides.length > 1 ? 28 : 10),
                      SlideTransition(
                        position: _slideUpAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              AppButton(
                                text: 'SIGN IN',
                                onPressed: () => _showLoginOptionsBottomSheet(context),
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.secondary.withValues(alpha: 0.85)],
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
                                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                              ),
                              const SizedBox(height: 16),
                              AppButton(
                                text: 'CREATE NEW ACCOUNT',
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
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
                                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom > 0 ? 0 : 10.0,
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
                              const TextSpan(text: 'By continuing, you agree to Amoura\'s '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.pinkAccent,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TermsOfServiceView(),
                                    ),
                                  ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.pinkAccent,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const PrivacyPolicyView(),
                                    ),
                                  ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ).animate(delay: 500.ms).fadeIn(duration: 600.ms),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom > 0 ? 8 : 18,
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