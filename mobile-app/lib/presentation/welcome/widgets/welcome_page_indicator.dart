// lib/presentation/welcome/widgets/welcome_page_indicator.dart

import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class WelcomePageIndicator extends StatelessWidget {
  final int currentPage;
  final int slideCount;
  const WelcomePageIndicator({super.key, required this.currentPage, required this.slideCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(slideCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          height: 8.5,
          width: currentPage == index ? 26.0 : 8.5,
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppColors.secondary
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}