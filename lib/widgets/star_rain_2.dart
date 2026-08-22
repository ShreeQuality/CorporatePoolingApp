import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Variation 2: Multi-Depth 3D Parallax Celestial Meteor Shower (Rain 2)
/// Features 3 independent depth planes:
///   - Far Layer: Microscopic background cosmos (slow, delicate)
///   - Mid Layer: Ambient stardust drift (smooth 12° celestial angle)
///   - Near Layer: Luminous shooting meteors with soft trailing comet tails
class StarRain2 extends StatefulWidget {
  final Rect? exclusionZone;
  final Widget? child;

  const StarRain2({
    super.key,
    this.exclusionZone,
    this.child,
  });

  @override
  State<StarRain2> createState() => _StarRain2State();
}

class _StarRain2State extends State<StarRain2>
    with SingleTickerProviderStateMixin {
  late AnimationController _driftController;
  late final List<ParallaxMeteor2> _particles;

  @override
  void initState() {
    super.initState();

    final random = math.Random(202);
    // 180 Multi-Depth Parallax Particles
    _particles = List.generate(180, (i) {
      final int depthTier = i % 3; // 0: Far, 1: Mid, 2: Near Comet

      double speed;
      double radius;
      double tailLength;
      double brightness;

      if (depthTier == 0) {
        // Far Cosmos Layer (Tiny, Slow)
        speed = 0.08 + random.nextDouble() * 0.10;
        radius = 0.40 + random.nextDouble() * 0.30;
        tailLength = 1.0;
        brightness = 0.35 + random.nextDouble() * 0.30;
      } else if (depthTier == 1) {
        // Mid Field Stardust (Medium)
        speed = 0.20 + random.nextDouble() * 0.25;
        radius = 0.70 + random.nextDouble() * 0.40;
        tailLength = 3.0 + random.nextDouble() * 4.0;
        brightness = 0.65 + random.nextDouble() * 0.30;
      } else {
        // Near Field Radiant Comets (Fast, Luminous with Soft Comet Tail)
        speed = 0.45 + random.nextDouble() * 0.50;
        radius = 1.10 + random.nextDouble() * 0.60;
        tailLength = 8.0 + random.nextDouble() * 14.0;
        brightness = 0.85 + random.nextDouble() * 0.15;
      }

      return ParallaxMeteor2(
        startX: random.nextDouble(),
        startY: random.nextDouble(),
        radius: radius,
        speed: speed,
        tailLength: tailLength,
        brightness: brightness,
        depthTier: depthTier,
        shimmerPhase: random.nextDouble() * 2 * math.pi,
      );
    });

    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
          child: AnimatedBuilder(
            animation: _driftController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParallaxCelestialShowerPainter2(
                  particles: _particles,
                  progress: _driftController.value,
                  exclusionZone: widget.exclusionZone,
                ),
              );
            },
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class ParallaxMeteor2 {
  final double startX;
  final double startY;
  final double radius;
  final double speed;
  final double tailLength;
  final double brightness;
  final int depthTier;
  final double shimmerPhase;

  const ParallaxMeteor2({
    required this.startX,
    required this.startY,
    required this.radius,
    required this.speed,
    required this.tailLength,
    required this.brightness,
    required this.depthTier,
    required this.shimmerPhase,
  });
}

/// 🌠 Rain 2 Painter: 3D Parallax Celestial Shower (12° Natural Radiant Angle)
class ParallaxCelestialShowerPainter2 extends CustomPainter {
  final List<ParallaxMeteor2> particles;
  final double progress;
  final Rect? exclusionZone;

  ParallaxCelestialShowerPainter2({
    required this.particles,
    required this.progress,
    this.exclusionZone,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 12° Celestial Drift Angle: (dx = sin(12°), dy = cos(12°))
    const double angleRad = 12.0 * math.pi / 180.0;
    final double dirX = math.sin(angleRad); // ~0.208
    final double dirY = math.cos(angleRad); // ~0.978

    final headPaint = Paint()..style = PaintingStyle.fill;
    final tailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final auraPaint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      // Smooth continuous wrapping:
      final double currentY = ((p.startY + progress * p.speed * dirY) % 1.0) * size.height;
      final double currentX = ((p.startX + progress * p.speed * dirX) % 1.0) * size.width;

      if (exclusionZone != null && exclusionZone!.contains(Offset(currentX, currentY))) {
        continue;
      }

      // Shimmer wave
      final double wave = (math.sin(progress * 2 * math.pi * 3.0 + p.shimmerPhase) + 1) / 2;
      final double alpha = (p.brightness * (0.60 + wave * 0.40)).clamp(0.15, 1.0);

      // Tail start position (following the 12° angle backwards)
      final double tailStartX = currentX - (dirX * p.tailLength);
      final double tailStartY = currentY - (dirY * p.tailLength);

      // 1. Radiant Comet Tail with gradient fade
      if (p.depthTier > 0) {
        final tailGradient = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: alpha * (p.depthTier == 2 ? 0.50 : 0.25)),
            ],
          ).createShader(Rect.fromPoints(
            Offset(tailStartX, tailStartY),
            Offset(currentX, currentY),
          ))
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = p.radius * (p.depthTier == 2 ? 1.0 : 0.8);

        canvas.drawLine(
          Offset(tailStartX, tailStartY),
          Offset(currentX, currentY),
          tailGradient,
        );
      }

      // 2. Near Field Soft Aura
      if (p.depthTier == 2 && wave > 0.3) {
        auraPaint.color = Colors.white.withValues(alpha: wave * 0.20);
        canvas.drawCircle(Offset(currentX, currentY), p.radius + 3.0, auraPaint);
      }

      // 3. Crisp White Laser Core Head
      headPaint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(currentX, currentY), p.radius, headPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ParallaxCelestialShowerPainter2 oldDelegate) =>
      oldDelegate.progress != progress;
}
