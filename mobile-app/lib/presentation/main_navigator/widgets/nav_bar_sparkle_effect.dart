import 'dart:math';
import 'package:flutter/material.dart';
import 'package:particle_field/particle_field.dart';
import '../../../core/constants/asset_path.dart';

class NavBarSparkleEffect extends StatelessWidget {
  final bool show;
  final double size;

  // Hiệu ứng chỉ xuất hiện khi show = true, size = kích thước icon
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
          // Tạo hiệu ứng sparkle từ chính giữa icon
          for (int i = 0; i < 15; i++) {
            particles.add(
              Particle(
                // Đặt vị trí xuất phát chính xác ở giữa
                x: fieldSize.width / 2,
                y: fieldSize.height / 2,
                // Hướng di chuyển đa dạng hơn theo hình sao
                vx: (r.nextDouble() * 60 - 30) * (r.nextBool() ? 1 : -1),
                vy: (r.nextDouble() * 60 - 30) * (r.nextBool() ? 1 : -1),
                // thời gian hiện thị để hiệu ứng
                lifespan: 0.3 + r.nextDouble() * 0.2,
                frame: r.nextInt(4),
                // Đa dạng kích thước
                scale: 0.5 + r.nextDouble() * 0.6,
              ),
            );
          }
          controller.particles = particles;
        },
      ),
    );
  }
}