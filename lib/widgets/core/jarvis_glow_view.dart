import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A futuristic, holographic HUD custom painter inspired by the Iron Man J.A.R.V.I.S.
/// interface and Arc Reactor aesthetics.
///
/// Features multi-layered glowing concentric rings, rotating segmented arcs,
/// sweep and radial energy gradients, orbiting data nodes, and neon glow effects.
class JarvisGlowPainter extends CustomPainter {
  /// Primary animation progress (0.0 to 1.0) controlling continuous rotation and energy flow.
  final double progress;

  /// Secondary animation progress (0.0 to 1.0) controlling pulse frequency and core breathing.
  final double pulse;

  /// Core cyan/blue theme colors for the holographic HUD.
  final Color primaryGlowColor;
  final Color secondaryGlowColor;
  final Color accentColor;
  final Color coreEnergyColor;

  JarvisGlowPainter({
    required this.progress,
    this.pulse = 0.5,
    this.primaryGlowColor = const Color(0xFF00E5FF),     // Electric Cyan
    this.secondaryGlowColor = const Color(0xFF0059B2),   // Deep Holographic Blue
    this.accentColor = const Color(0xFF80D8FF),          // Soft Neon Ice Blue
    this.coreEnergyColor = const Color(0xFFFFFFFF),      // Blinding White Core
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;
    if (maxRadius <= 0) return;

    final rotationAngle = progress * 2 * math.pi;
    final pulseScale = 0.85 + (pulse * 0.15); // Breathing ratio

    // 1. Deep Background Radial Glow (Ambient Hologram)
    _drawAmbientBackdrop(canvas, center, maxRadius);

    // 2. Outermost Segmented HUD Ticks (Calibrated Measurement Ring)
    _drawOuterCalibratedTicks(canvas, center, maxRadius * 0.95, rotationAngle * 0.5);

    // 3. Counter-Rotating Swept Energy Arcs
    _drawSweptEnergyArcs(canvas, center, maxRadius * 0.82, -rotationAngle * 1.2);

    // 4. Glowing Concentric Track with Orbital Nodes
    _drawOrbitalNodesRing(canvas, center, maxRadius * 0.68, rotationAngle * 0.8);

    // 5. High-Frequency Hexagonal / Segmented Reticle Ring
    _drawInnerReticleRing(canvas, center, maxRadius * 0.52, -rotationAngle * 0.6);

    // 6. Arc Reactor Core Glow & Pulsing Energy Rings
    _drawArcReactorCore(canvas, center, maxRadius * 0.35 * pulseScale, rotationAngle);
  }

  /// Ambient background radial diffusion
  void _drawAmbientBackdrop(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryGlowColor.withValues(alpha: 0.25),
          secondaryGlowColor.withValues(alpha: 0.10),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  /// Outermost ring with fine tick marks and angular compass accents
  void _drawOuterCalibratedTicks(Canvas canvas, Offset center, double radius, double rotation) {
    final tickPaint = Paint()
      ..color = primaryGlowColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final boldTickPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.9)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.0);

    const int totalTicks = 72;
    for (int i = 0; i < totalTicks; i++) {
      final angle = rotation + (i * 2 * math.pi / totalTicks);
      final isMajor = i % 6 == 0;
      final isCardinal = i % 18 == 0;

      final tickLength = isCardinal ? 14.0 : (isMajor ? 8.0 : 4.0);
      final innerR = radius - tickLength;
      final outerR = radius;

      final p1 = Offset(center.dx + innerR * math.cos(angle), center.dy + innerR * math.sin(angle));
      final p2 = Offset(center.dx + outerR * math.cos(angle), center.dy + outerR * math.sin(angle));

      canvas.drawLine(p1, p2, isMajor ? boldTickPaint : tickPaint);
    }

    // Outer boundary ring with neon blur
    final borderGlow = Paint()
      ..color = primaryGlowColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    canvas.drawCircle(center, radius, borderGlow);
  }

  /// Multi-segment energy arcs rendered with sweep gradients
  void _drawSweptEnergyArcs(Canvas canvas, Offset center, double radius, double rotation) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Dynamic sweep gradient paint
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          primaryGlowColor.withValues(alpha: 0.1),
          primaryGlowColor,
          accentColor,
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.7, 0.9, 1.0],
        transform: GradientRotation(rotation),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Glowing duplicate
    final glowPaint = Paint()
      ..shader = sweepPaint.shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    // Draw opposing arcs
    canvas.drawArc(rect, rotation, math.pi * 0.75, false, glowPaint);
    canvas.drawArc(rect, rotation, math.pi * 0.75, false, sweepPaint);

    canvas.drawArc(rect, rotation + math.pi, math.pi * 0.75, false, glowPaint);
    canvas.drawArc(rect, rotation + math.pi, math.pi * 0.75, false, sweepPaint);
  }

  /// Middle orbital track with glowing particle nodes and dashed lines
  void _drawOrbitalNodesRing(Canvas canvas, Offset center, double radius, double rotation) {
    final linePaint = Paint()
      ..color = primaryGlowColor.withValues(alpha: 0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, linePaint);

    // Orbiting energy nodes
    const nodeCount = 4;
    for (int i = 0; i < nodeCount; i++) {
      final nodeAngle = rotation + (i * 2 * math.pi / nodeCount);
      final nodePos = Offset(
        center.dx + radius * math.cos(nodeAngle),
        center.dy + radius * math.sin(nodeAngle),
      );

      // Node aura
      final auraPaint = Paint()
        ..color = primaryGlowColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      canvas.drawCircle(nodePos, 5.0, auraPaint);

      // Node solid center
      final centerPaint = Paint()..color = coreEnergyColor;
      canvas.drawCircle(nodePos, 2.5, centerPaint);
    }
  }

  /// Inner segmented reticle with precision angle notches
  void _drawInnerReticleRing(Canvas canvas, Offset center, double radius, double rotation) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final arcPaint = Paint()
      ..color = primaryGlowColor.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Segmented brackets
    const segments = 3;
    const sweep = (2 * math.pi / segments) * 0.6;
    for (int i = 0; i < segments; i++) {
      final startAngle = rotation + (i * 2 * math.pi / segments);
      canvas.drawArc(rect, startAngle, sweep, false, arcPaint);
    }
  }

  /// Central Arc Reactor core featuring intensive radial emission and iris rings
  void _drawArcReactorCore(Canvas canvas, Offset center, double coreRadius, double rotation) {
    final rect = Rect.fromCircle(center: center, radius: coreRadius);

    // Intense outer bloom
    final bloomPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          coreEnergyColor,
          primaryGlowColor,
          secondaryGlowColor.withValues(alpha: 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.75, 1.0],
      ).createShader(rect);

    canvas.drawCircle(center, coreRadius * 1.4, bloomPaint);

    // Inner mechanical iris ring
    final irisPaint = Paint()
      ..color = primaryGlowColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.0);

    canvas.drawCircle(center, coreRadius * 0.65, irisPaint);

    // Rotating inner energy blades
    final bladePaint = Paint()
      ..color = coreEnergyColor.withValues(alpha: 0.9)
      ..strokeWidth = 1.8;

    const bladeCount = 6;
    for (int i = 0; i < bladeCount; i++) {
      final angle = rotation * 1.5 + (i * math.pi / 3);
      final p1 = Offset(center.dx + (coreRadius * 0.2) * math.cos(angle), center.dy + (coreRadius * 0.2) * math.sin(angle));
      final p2 = Offset(center.dx + (coreRadius * 0.6) * math.cos(angle), center.dy + (coreRadius * 0.6) * math.sin(angle));
      canvas.drawLine(p1, p2, bladePaint);
    }

    // Pure white singularity core
    final coreDot = Paint()
      ..color = coreEnergyColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0);
    canvas.drawCircle(center, coreRadius * 0.22, coreDot);
  }

  @override
  bool shouldRepaint(covariant JarvisGlowPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulse != pulse ||
        oldDelegate.primaryGlowColor != primaryGlowColor ||
        oldDelegate.secondaryGlowColor != secondaryGlowColor;
  }
}

/// A ready-to-use animated widget wrapping [JarvisGlowPainter].
class JarvisGlowView extends StatefulWidget {
  final double size;
  final Duration rotationDuration;
  final Duration pulseDuration;
  final Color primaryGlowColor;
  final Color secondaryGlowColor;
  final Color accentColor;
  final Color coreEnergyColor;

  const JarvisGlowView({
    super.key,
    this.size = 300.0,
    this.rotationDuration = const Duration(seconds: 10),
    this.pulseDuration = const Duration(milliseconds: 1800),
    this.primaryGlowColor = const Color(0xFF00E5FF),
    this.secondaryGlowColor = const Color(0xFF0059B2),
    this.accentColor = const Color(0xFF80D8FF),
    this.coreEnergyColor = const Color(0xFFFFFFFF),
  });

  @override
  State<JarvisGlowView> createState() => _JarvisGlowViewState();
}

class _JarvisGlowViewState extends State<JarvisGlowView> with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _pulseAnimation]),
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: JarvisGlowPainter(
            progress: _rotationController.value,
            pulse: _pulseAnimation.value,
            primaryGlowColor: widget.primaryGlowColor,
            secondaryGlowColor: widget.secondaryGlowColor,
            accentColor: widget.accentColor,
            coreEnergyColor: widget.coreEnergyColor,
          ),
        );
      },
    );
  }
}
