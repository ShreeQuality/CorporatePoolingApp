import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Variation 1: Linear Vertical Cosmic Stardust Rainfall (Ultra-Optimized 120fps)
class StarRain1 extends StatefulWidget {
  final Rect? exclusionZone;
  final Widget? child;

  const StarRain1({
    super.key,
    this.exclusionZone,
    this.child,
  });

  @override
  State<StarRain1> createState() => _StarRain1State();
}

class _StarRain1State extends State<StarRain1>
    with SingleTickerProviderStateMixin {
  late AnimationController _driftController;
  late final List<StardustParticle1> _particles;

  @override
  void initState() {
    super.initState();

    final random = math.Random(101);
    // 100 Optimized High-Performance Stardust Particles
    _particles = List.generate(100, (i) {
      return StardustParticle1(
        startX: random.nextDouble(),
        startY: random.nextDouble(),
        radius: 0.45 + random.nextDouble() * 0.65,
        brightness: 0.70 + random.nextDouble() * 0.30,
        twinklePhase: random.nextDouble() * 2 * math.pi,
        streakLength: 1.5 + random.nextDouble() * 3.5,
      );
    });

    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    )..repeat();
  }

  @override
  void dispose() {
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _driftController,
              builder: (context, child) {
                return CustomPaint(
                  painter: CosmicDriftingStardustPainter1(
                    particles: _particles,
                    progress: _driftController.value,
                    exclusionZone: widget.exclusionZone,
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class StardustParticle1 {
  final double startX;
  final double startY;
  final double radius;
  final double brightness;
  final double twinklePhase;
  final double streakLength;

  const StardustParticle1({
    required this.startX,
    required this.startY,
    required this.radius,
    required this.brightness,
    required this.twinklePhase,
    required this.streakLength,
  });
}

class CosmicDriftingStardustPainter1 extends CustomPainter {
  final List<StardustParticle1> particles;
  final double progress;
  final Rect? exclusionZone;

  // Pre-allocated reusable Paint objects to eliminate GC allocation spikes
  final Paint _corePaint = Paint()
    ..style = PaintingStyle.fill
    ..strokeCap = StrokeCap.round;

  final Paint _streakPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  CosmicDriftingStardustPainter1({
    required this.particles,
    required this.progress,
    this.exclusionZone,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double fullHeight = size.height + 50.0;
    const double twoPi = 2 * math.pi;

    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      final double normalizedY = (p.startY + progress) % 1.0;
      final double currentY = (normalizedY * fullHeight) - 25.0;
      final double currentX = p.startX * size.width;

      if (exclusionZone != null) {
        final double dx = currentX - exclusionZone!.center.dx;
        final double dy = currentY - exclusionZone!.center.dy;
        final double maxR = exclusionZone!.width / 2;
        if ((dx * dx + dy * dy) <= (maxR * maxR)) {
          continue;
        }
      }

      final double wave = (math.sin(progress * twoPi * 3.0 + p.twinklePhase) + 1.0) * 0.5;
      final double alpha = (p.brightness * (0.55 + wave * 0.45)).clamp(0.2, 1.0);

      final int alpha255 = (alpha * 255).round().clamp(0, 255);
      final int streakAlpha255 = (alpha * 0.35 * 255).round().clamp(0, 255);

      // 1. Subtle original micro tail streak (zero object allocations)
      _streakPaint
        ..color = Color.fromARGB(streakAlpha255, 255, 255, 255)
        ..strokeWidth = p.radius * 0.9;
      canvas.drawLine(
        Offset(currentX, currentY - p.streakLength),
        Offset(currentX, currentY),
        _streakPaint,
      );

      // 2. Crisp white star core
      _corePaint.color = Color.fromARGB(alpha255, 255, 255, 255);
      canvas.drawCircle(Offset(currentX, currentY), p.radius, _corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CosmicDriftingStardustPainter1 oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.exclusionZone != exclusionZone;
}
