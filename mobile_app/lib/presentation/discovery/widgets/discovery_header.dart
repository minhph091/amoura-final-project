// lib/presentation/discovery/widgets/discovery_header.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/theme/app_colors.dart';
import 'filter/filter_dialog.dart';

class DiscoveryHeader extends StatelessWidget {
  const DiscoveryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Make status bar icons dark
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 4), // giảm margin để tránh lộ nền khi vuốt
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.98),
          borderRadius: BorderRadius.circular(12), // Bo góc đẹp hơn
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Amoura logo - làm nổi bật hơn
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  AppColors.primary,
                  Colors.purple.shade400,
                  AppColors.primary.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'Amoura',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white, // Màu này sẽ bị thay thế bởi gradient
                  fontFamily: 'Cursive',
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.purple.withOpacity(0.6),
                      offset: const Offset(1.5, 1.5),
                      blurRadius: 5,
                    ),
                    Shadow(
                      color: AppColors.primary.withOpacity(0.4),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            
            // Filter icon
            IconButton(
              onPressed: () => showFilterDialog(context),
              icon: const Icon(
                Icons.tune,
                color: AppColors.primary,
                size: 26,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
