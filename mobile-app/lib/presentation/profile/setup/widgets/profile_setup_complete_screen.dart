// lib/presentation/profile/setup/widgets/profile_setup_complete_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/app_gradient_background.dart';

class ProfileSetupCompleteScreen extends StatefulWidget {
  const ProfileSetupCompleteScreen({super.key});

  @override
  State<ProfileSetupCompleteScreen> createState() => _ProfileSetupCompleteScreenState();
}

class _ProfileSetupCompleteScreenState extends State<ProfileSetupCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _heartsController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _heartsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Start animations
    _confettiController.repeat();
    _heartsController.repeat();

    // Complete the profile setup
    _completeProfileSetup();

    // Auto navigate after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _navigateToMain();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _heartsController.dispose();
    super.dispose();
  }

  Future<void> _completeProfileSetup() async {
    try {
      print('Profile setup was completed successfully!');
    } catch (e) {
      print('Error in completion screen: $e');
    }
  }

  void _navigateToMain() {
    Navigator.pushReplacementNamed(context, '/mainNavigator');
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Confetti effect
            ...List.generate(
                20,
                (index) => ConfettiParticle(
                      index: index,
                      animation: _confettiController,
                    )),

            // Floating hearts
            ...List.generate(
                8,
                (index) => FloatingHeart(
                      index: index,
                      animation: _heartsController,
                    )),

            // Main content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success card
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Success icon
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4FACFE),
                                    Color(0xFF00F2FE)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4FACFE)
                                        .withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 40,
                              ),
                            ).animate().scale(
                                  duration: 800.ms,
                                  delay: 200.ms,
                                  curve: Curves.elasticOut,
                                ),
                            const SizedBox(height: 24),
                            // Title
                            Text(
                              'Profile Complete!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 400.ms)
                                .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  duration: 600.ms,
                                  delay: 400.ms,
                                ),
                            const SizedBox(height: 12),
                            // Subtitle
                            Text(
                              'Congratulations! Your profile is now ready to start connecting with amazing people. Let\'s begin your dating journey!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFF666666),
                                height: 1.5,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 600.ms)
                                .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  duration: 600.ms,
                                  delay: 600.ms,
                                ),
                            const SizedBox(height: 32),
                            // Start Dating button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/mainNavigator');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ).copyWith(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.transparent),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF667EEA),
                                        Color(0xFF764BA2)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF667EEA)
                                            .withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Start Dating',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 800.ms)
                                .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  duration: 600.ms,
                                  delay: 800.ms,
                                )
                                .then(delay: 1000.ms)
                                .shimmer(
                                  duration: 2000.ms,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOut,
                          ).scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: 500.ms,
                            curve: Curves.easeOut,
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfettiParticle extends StatelessWidget {
  final int index;
  final AnimationController animation;

  const ConfettiParticle({
    super.key,
    required this.index,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF4FACFE),
      const Color(0xFF667EEA),
      const Color(0xFFFF6B9D),
      const Color(0xFF4ECDC4),
    ];

    final delay = index * 0.1;
    final leftPosition = (index % 10) * 0.1;

    return Positioned(
      left: MediaQuery.of(context).size.width * leftPosition,
      top: -20,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final animationValue = (animation.value + delay) % 1.0;
          final y = animationValue * (MediaQuery.of(context).size.height + 100);
          final rotation = animationValue * 720;

          return Transform.translate(
            offset: Offset(0, y),
            child: Transform.rotate(
              angle: rotation * 3.14159 / 180,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FloatingHeart extends StatelessWidget {
  final int index;
  final AnimationController animation;

  const FloatingHeart({
    super.key,
    required this.index,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final hearts = ['💕', '❤️', '💖', '💝'];
    final delay = index * 0.2;
    final leftPosition = (index % 4) * 0.25 + 0.1;

    return Positioned(
      left: MediaQuery.of(context).size.width * leftPosition,
      bottom: -30,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final animationValue = (animation.value + delay) % 1.0;
          final y = animationValue * (MediaQuery.of(context).size.height + 100);
          final opacity = 1.0 - animationValue;
          final rotation = animationValue * 180;

          return Transform.translate(
            offset: Offset(0, -y),
            child: Transform.rotate(
              angle: rotation * 3.14159 / 180,
              child: Opacity(
                opacity: opacity,
                child: Text(
                  hearts[index % hearts.length],
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}