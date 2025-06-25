// lib/presentation/welcome/widgets/welcome_slide_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../welcome/welcome_view.dart';

class WelcomeSlideItem extends StatelessWidget {
  final WelcomeSlide slide;
  final int index;
  const WelcomeSlideItem({super.key, required this.slide, required this.index});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
        ).animate()
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
          bottom: MediaQuery.of(context).size.height * 0.38,
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
  }
}