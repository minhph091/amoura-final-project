import 'package:flutter/material.dart';
import 'dart:math' as math;

class ParticleSystem extends StatefulWidget {
  final bool isActive;
  final Color particleColor;

  const ParticleSystem({
    super.key,
    required this.isActive,
    required this.particleColor,
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _generateParticles();

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ParticleSystem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  void _generateParticles() {
    particles.clear();
    final random = math.Random();
    for (int i = 0; i < 8; i++) {
      particles.add(
        Particle(
          x: random.nextDouble() * 60 - 30,
          y: random.nextDouble() * 60 - 30,
          size: random.nextDouble() * 3 + 1,
          speed: random.nextDouble() * 0.5 + 0.2,
          angle: random.nextDouble() * 2 * math.pi,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(60, 60),
          painter: ParticlePainter(
            particles: particles,
            progress: _controller.value,
            color: widget.particleColor,
          ),
        );
      },
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double angle;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      final animatedProgress = (progress + particle.speed) % 1.0;
      final fadeProgress =
          animatedProgress < 0.7
              ? animatedProgress / 0.7
              : (1.0 - animatedProgress) / 0.3;

      final currentX =
          center.dx +
          particle.x *
              math.cos(particle.angle + progress * 2 * math.pi) *
              animatedProgress;
      final currentY =
          center.dy +
          particle.y *
              math.sin(particle.angle + progress * 2 * math.pi) *
              animatedProgress;

      paint.color = color.withValues(alpha: 0.6 * fadeProgress);

      canvas.drawCircle(
        Offset(currentX, currentY),
        particle.size * (1.0 - animatedProgress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
