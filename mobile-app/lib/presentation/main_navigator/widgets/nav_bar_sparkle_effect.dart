import 'dart:math';
import 'package:flutter/material.dart';
import 'package:particle_field/particle_field.dart';
import '../../../core/constants/asset_path.dart';

class NavBarSparkleEffect extends StatelessWidget {
  final bool show;
  final double size;

  /// Hiệu ứng chỉ xuất hiện khi show = true, size = kích thước icon
  const NavBarSparkleEffect({
    super.key,
    required this.show,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    return SizedBox(
      width: size,
      height: size,
      child: ParticleField(
        spriteSheet: SpriteSheet(
          image: const AssetImage(AssetPath.sparkleEffect),
          frameWidth: 32,
          frameHeight: 32,
        ),
        blendMode: BlendMode.srcIn,
        onTick: (controller, elapsed, fieldSize) {
          final r = Random();
          List<Particle> particles = [];
          // tạo hiệu ứng rơi xuống dưới từ center
          for (int i = 0; i < 12; i++) {
            particles.add(
              Particle(
                x: fieldSize.width / 2 + r.nextDouble() * 10 - 5,
                y: fieldSize.height / 2 + r.nextDouble() * 4 - 2,
                vx: r.nextDouble() * 8 - 4, // nhẹ sang trái phải
                vy: 30 + r.nextDouble() * 40, // rơi xuống dưới
                lifespan: 0.8 + r.nextDouble() * 0.4,
                frame: r.nextInt(4),
                scale: 0.6 + r.nextDouble() * 0.7,
              ),
            );
          }
          controller.particles = particles;
        },
      ),
    );
  }
}