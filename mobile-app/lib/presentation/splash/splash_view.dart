// lib/presentation/splash/splash_view.dart

import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../core/constants/asset_path.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _rotateAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _rotateAnim = Tween<double>(begin: -0.15, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient _getSplashGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF23223B),
        Color(0xFF3A374D),
        Color(0xFFFC5185),
      ],
    )
        : const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFCEFF9),
        Color(0xFFFF8FB2),
        Color(0xFFFC5185),
        Color(0xFF364F6B),
      ],
      stops: [0.02, 0.42, 0.7, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: _getSplashGradient(context),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Opacity(
              opacity: _fadeAnim.value,
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: Transform.rotate(
                  angle: _rotateAnim.value,
                  child: child,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo + hiệu ứng glow/shadow + Hero
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.10),
                          blurRadius: 38,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: (isDark ? AppColors.darkSecondary : AppColors.secondary)
                              .withValues(alpha: 0.20),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                              .withValues(alpha: 0.17),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AssetPath.logo,
                      width: 96,
                      height: 96,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                // Tiêu đề Amoura - luôn trắng và có shadow
                Text(
                  'Amoura',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.1,
                    shadows: [
                      Shadow(
                        blurRadius: 12,
                        color: Colors.black.withValues(alpha: 0.32),
                        offset: const Offset(0, 3),
                      ),
                      Shadow(
                        blurRadius: 6,
                        color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                            .withValues(alpha: 0.13),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your Journey to Love Starts Here',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.88)
                        : const Color(0xFFCFFFFA),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}