import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Screen 1 Emblem: Sacred Animated Sudarshan Chakra (V11-V4: Charge & Snap / Kinetic Tension & Elastic Recoil)
/// Pattern:
///   - Phase 1 (Charge & Compression): 0.00 -> 0.65 (~2080ms). Inward compression (1.0 -> 0.94) + accelerating high-voltage tremor
///   - Phase 2 (Explosive Snap): 0.65 -> 0.72 (~220ms). Instantaneous whip-crack elastic recoil (0.94 -> 1.07)
///   - Phase 3 (Damped Ring-Down): 0.72 -> 1.00 (~900ms). Spring-damped harmonic decay returning to rest
///   - Total Cycle: 3200ms
///   - Continuous Independent Rotations:
///       * Outermost Perimeter Ring (R=454 with 36 clean monoline blade teeth): Clockwise (10s)
///       * Dashed Arc Circle (- - -) at R=414: Anti-Clockwise (6.5s)
///       * Main Sacred Wheel (R=426 to Hub): Clockwise (8s)
///       * Outer Fire Hexagon Star: Clockwise (5.5s)
///       * Inner Fire Hexagon Star: Anti-Clockwise (4.5s)
class SudarshanChakra11V4 extends StatefulWidget {
  const SudarshanChakra11V4({
    super.key,
    this.size = 170,
    this.speed = 1.0,
  });

  final double size;
  final double speed;

  @override
  State<SudarshanChakra11V4> createState() => _SudarshanChakra11V4State();
}

class _SudarshanChakra11V4State extends State<SudarshanChakra11V4>
    with TickerProviderStateMixin {
  late final AnimationController _outermostRingController;
  late final AnimationController _wheelController;
  late final AnimationController _dashedRingController;
  late final AnimationController _fireClockwiseController;
  late final AnimationController _fireAntiClockwiseController;
  late final AnimationController _glowController;
  late final AnimationController _chargeSnapController;

  @override
  void initState() {
    super.initState();

    // 1. Outermost Perimeter Circle with 36 Blade Teeth rotates independently (10000ms)
    _outermostRingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (10000 / widget.speed).round()),
    )..repeat();

    // 2. Main Wheel rotates Clockwise (8000ms)
    _wheelController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (8000 / widget.speed).round()),
    )..repeat();

    // 3. Dashed Arc Circle (- - -) rotates Anti-Clockwise (6500ms)
    _dashedRingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (6500 / widget.speed).round()),
    )..repeat();

    // 4. Outer Fire Hexagon Star rotates Clockwise (5500ms)
    _fireClockwiseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (5500 / widget.speed).round()),
    )..repeat();

    // 5. Inner Fire Hexagon Star rotates Anti-Clockwise (4500ms)
    _fireAntiClockwiseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (4500 / widget.speed).round()),
    )..repeat();

    // 6. Ambient Breathing Glow (2400ms)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // 7. Charge & Snap Cycle: 3200ms
    _chargeSnapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _outermostRingController.dispose();
    _wheelController.dispose();
    _dashedRingController.dispose();
    _fireClockwiseController.dispose();
    _fireAntiClockwiseController.dispose();
    _glowController.dispose();
    _chargeSnapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.65,
      height: widget.size * 1.15,
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _outermostRingController,
            _wheelController,
            _dashedRingController,
            _fireClockwiseController,
            _fireAntiClockwiseController,
            _glowController,
            _chargeSnapController,
          ]),
          builder: (context, _) {
            final t = _chargeSnapController.value;

            double tremorX = 0, tremorY = 0;
            double dynamicScale = 1.0;
            double auraSurge = 0.0;

            // 1. PHASE 1: CHARGE & TENSE COMPRESSION (0.00 -> 0.65)
            if (t < 0.65) {
              final p = t / 0.65; // 0.0 -> 1.0
              // Inward elastic compression: 1.0 -> 0.94
              dynamicScale = 1.0 - (0.06 * math.pow(p, 1.8));

              // Accelerating frequency and building tremor intensity
              final freq = 6.0 + (18.0 * p); // 6Hz -> 24Hz
              final intensity = 0.4 + (2.6 * math.pow(p, 2.0));
              tremorX = math.sin(p * freq * math.pi * 2) * intensity;
              tremorY = math.cos(p * freq * math.pi * 2) * (intensity * 0.75);
              auraSurge = 0.10 * math.pow(p, 2.0);
            }
            // 2. PHASE 2: EXPLOSIVE "SNAP" RELEASE (0.65 -> 0.72)
            else if (t >= 0.65 && t < 0.72) {
              final p = (t - 0.65) / 0.07; // 0.0 -> 1.0
              // Rapid whip-crack expansion: 0.94 -> 1.07
              dynamicScale = 0.94 + (0.13 * math.sin(p * math.pi * 0.5));
              // High-energy shockwave tremor
              final env = math.sin(p * math.pi);
              tremorX = math.sin(p * 8 * math.pi * 2) * 3.8 * env;
              tremorY = math.cos(p * 8 * math.pi * 2) * 2.8 * env;
              auraSurge = 0.25 * env;
            }
            // 3. PHASE 3: DAMPED OSCILLATION RING-DOWN (0.72 -> 1.00)
            else {
              final p = (t - 0.72) / 0.28; // 0.0 -> 1.0
              final decay = math.exp(-p * 4.5); // Fast exponential decay
              // Spring harmonic damped oscillation around 1.0
              dynamicScale = 1.0 + (0.07 * decay * math.cos(p * 4 * math.pi));
              tremorX = math.sin(p * 6 * math.pi * 2) * 1.5 * decay;
              tremorY = math.cos(p * 6 * math.pi * 2) * 1.0 * decay;
              auraSurge = 0.10 * decay;
            }

            final baseGlow = _glowController.value;
            final glowScale = 1.62 + (baseGlow * 0.08) + auraSurge;

            return Stack(
              alignment: Alignment.center,
              children: [
                // 1. Tilted 3D Ground Shadow
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(glowScale, glowScale, 1.0)
                    ..rotateX(-54 * math.pi / 180)
                    ..rotateZ(10 * math.pi / 180),
                  child: Container(
                    width: widget.size * 0.88,
                    height: widget.size * 0.88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFF9D00).withValues(alpha: 0.35 + auraSurge),
                          const Color(0xFFFF5500).withValues(alpha: 0.18 + (auraSurge * 0.5)),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.50, 1.0],
                      ),
                    ),
                  ),
                ),

                // 2. 3D Tilt Container with Charge & Snap Recoil
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(1.60 * dynamicScale, 1.60 * dynamicScale, 1.0)
                    ..rotateX(-54 * math.pi / 180)
                    ..rotateZ(10 * math.pi / 180),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // LAYER 0: Outermost Perimeter Circle with 36 Blade Teeth (Spins independently at 10s CW)
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..translate(tremorX, tremorY, 0.0),
                        child: Transform.rotate(
                          angle: _outermostRingController.value * math.pi * 2,
                          child: SvgPicture.string(
                            _outermostRingSvgData,
                            width: widget.size,
                            height: widget.size,
                          ),
                        ),
                      ),

                      // LAYER 1: Main Sacred Wheel (Spins Clockwise at 8s)
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..translate(tremorX, tremorY, 0.0),
                        child: Transform.rotate(
                          angle: _wheelController.value * math.pi * 2,
                          child: SvgPicture.string(
                            _wheelSvgData,
                            width: widget.size,
                            height: widget.size,
                          ),
                        ),
                      ),

                      // LAYER 1B: Dashed Circle Line (- - -) (Spins Anti-Clockwise at 6.5s)
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..translate(tremorX, tremorY, 0.0),
                        child: Transform.rotate(
                          angle: -_dashedRingController.value * math.pi * 2,
                          child: SvgPicture.string(
                            _dashedRingSvgData,
                            width: widget.size,
                            height: widget.size,
                          ),
                        ),
                      ),

                      // LAYER 2: Outer Fire Star (Spins Clockwise at 5.5s)
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..translate(tremorX * 0.9, tremorY * 0.9, 0.0),
                        child: Transform.rotate(
                          angle: _fireClockwiseController.value * math.pi * 2,
                          child: SvgPicture.string(
                            _fireClockwiseSvgData,
                            width: widget.size,
                            height: widget.size,
                          ),
                        ),
                      ),

                      // LAYER 3: Inner Fire Star (Spins Anti-Clockwise at 4.5s)
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..translate(tremorX * 1.1, tremorY * 1.1, 0.0),
                        child: Transform.rotate(
                          angle: -_fireAntiClockwiseController.value * math.pi * 2,
                          child: SvgPicture.string(
                            _fireAntiClockwiseSvgData,
                            width: widget.size,
                            height: widget.size,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static const String _outermostRingSvgData = r"""<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <!-- Outermost Rotating Perimeter Circle R=454 (Exact V4 Linework) -->
  <circle cx="512" cy="512" r="454" fill="none" stroke="#ff8b12" stroke-width="2.5" />
  <circle cx="512" cy="512" r="444" fill="none" stroke="#ffb01a" stroke-width="3.5" />
  <!-- 36 Outer Rotating Blade Teeth (Clean Monoline V4 Style) -->
  <g fill="none" stroke="#ff8b12" stroke-width="2.0">
    <polygon points="966.0,512.0 979.7,528.3 964.9,543.7" />
    <polygon points="959.1,590.8 969.8,609.3 952.5,621.8" />
    <polygon points="938.6,667.3 945.9,687.3 926.7,696.7" />
    <polygon points="905.2,739.0 908.9,760.0 888.4,765.9" />
    <polygon points="859.8,803.8 859.8,825.2 838.6,827.4" />
    <polygon points="803.8,859.8 800.1,880.8 778.9,879.3" />
    <polygon points="739.0,905.2 731.7,925.2 711.0,920.1" />
    <polygon points="667.3,938.6 656.6,957.1 637.1,948.4" />
    <polygon points="590.8,959.1 577.1,975.4 559.5,963.5" />
    <polygon points="512.0,966.0 495.7,979.7 480.3,964.9" />
    <polygon points="433.2,959.1 414.7,969.8 402.2,952.5" />
    <polygon points="356.7,938.6 336.7,945.9 327.3,926.7" />
    <polygon points="285.0,905.2 264.0,908.9 258.1,888.4" />
    <polygon points="220.2,859.8 198.8,859.8 196.6,838.6" />
    <polygon points="164.2,803.8 143.2,800.1 144.7,778.9" />
    <polygon points="118.8,739.0 98.8,731.7 103.9,711.0" />
    <polygon points="85.4,667.3 66.9,656.6 75.6,637.1" />
    <polygon points="64.9,590.8 48.6,577.1 60.5,559.5" />
    <polygon points="58.0,512.0 44.3,495.7 59.1,480.3" />
    <polygon points="64.9,433.2 54.2,414.7 71.5,402.2" />
    <polygon points="85.4,356.7 78.1,336.7 97.3,327.3" />
    <polygon points="118.8,285.0 115.1,264.0 135.6,258.1" />
    <polygon points="164.2,220.2 164.2,198.8 185.4,196.6" />
    <polygon points="220.2,164.2 223.9,143.2 245.1,144.7" />
    <polygon points="285.0,118.8 292.3,98.8 313.0,103.9" />
    <polygon points="356.7,85.4 367.4,66.9 386.9,75.6" />
    <polygon points="433.2,64.9 446.9,48.6 464.5,60.5" />
    <polygon points="512.0,58.0 528.3,44.3 543.7,59.1" />
    <polygon points="590.8,64.9 609.3,54.2 621.8,71.5" />
    <polygon points="667.3,85.4 687.3,78.1 696.7,97.3" />
    <polygon points="739.0,118.8 760.0,115.1 765.9,135.6" />
    <polygon points="803.8,164.2 825.2,164.2 827.4,185.4" />
    <polygon points="859.8,220.2 880.8,223.9 879.3,245.1" />
    <polygon points="905.2,285.0 925.2,292.3 920.1,313.0" />
    <polygon points="938.6,356.7 957.1,367.4 948.4,386.9" />
    <polygon points="959.1,433.2 975.4,446.9 963.5,464.5" />
  </g>
</svg>""";

  static const String _wheelSvgData = r"""<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="core" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#fff6a0" />
      <stop offset="35%" stop-color="#ffd33d" />
      <stop offset="100%" stop-color="#ff7a00" stop-opacity="0" />
    </radialGradient>
  </defs>

  <path d="M 512 282 A 230 230 0 1 0 512 742 A 230 230 0 1 0 512 282 Z" fill="url(#core)" opacity="0.25" />

  <!-- Outer Solid Circles -->
  <g fill="none" stroke="#ff8b12">
    <path d="M 512 86 A 426 426 0 1 0 512 938 A 426 426 0 1 0 512 86 Z" stroke-width="2" />
    <path d="M 512 107 A 405 405 0 1 0 512 917 A 405 405 0 1 0 512 107 Z" stroke-width="3" />
    <path d="M 512 125 A 387 387 0 1 0 512 899 A 387 387 0 1 0 512 125 Z" stroke-width="2" />
    <path d="M 512 152 A 360 360 0 1 0 512 872 A 360 360 0 1 0 512 152 Z" stroke-width="4" />
    <path d="M 512 170 A 342 342 0 1 0 512 854 A 342 342 0 1 0 512 170 Z" stroke-width="2" />
  </g>

  <!-- 24 Calibration Dots -->
  <g fill="#ffb21a">
    <path d="M 561.9 130.3 A 3.5 3.5 0 1 0 561.9 137.3 A 3.5 3.5 0 1 0 561.9 130.3 Z" />
    <path d="M 658.2 156.1 A 3.5 3.5 0 1 0 658.2 163.1 A 3.5 3.5 0 1 0 658.2 156.1 Z" />
    <path d="M 744.5 205.9 A 3.5 3.5 0 1 0 744.5 212.9 A 3.5 3.5 0 1 0 744.5 205.9 Z" />
    <path d="M 815.1 276.5 A 3.5 3.5 0 1 0 815.1 283.5 A 3.5 3.5 0 1 0 815.1 276.5 Z" />
    <path d="M 864.9 362.8 A 3.5 3.5 0 1 0 864.9 369.8 A 3.5 3.5 0 1 0 864.9 362.8 Z" />
    <path d="M 890.7 459.1 A 3.5 3.5 0 1 0 890.7 466.1 A 3.5 3.5 0 1 0 890.7 459.1 Z" />
    <path d="M 890.7 558.9 A 3.5 3.5 0 1 0 890.7 565.9 A 3.5 3.5 0 1 0 890.7 558.9 Z" />
    <path d="M 864.9 655.2 A 3.5 3.5 0 1 0 864.9 662.2 A 3.5 3.5 0 1 0 864.9 655.2 Z" />
    <path d="M 815.1 741.5 A 3.5 3.5 0 1 0 815.1 748.5 A 3.5 3.5 0 1 0 815.1 741.5 Z" />
    <path d="M 744.5 812.1 A 3.5 3.5 0 1 0 744.5 819.1 A 3.5 3.5 0 1 0 744.5 812.1 Z" />
    <path d="M 658.2 861.9 A 3.5 3.5 0 1 0 658.2 868.9 A 3.5 3.5 0 1 0 658.2 861.9 Z" />
    <path d="M 561.9 887.7 A 3.5 3.5 0 1 0 561.9 894.7 A 3.5 3.5 0 1 0 561.9 887.7 Z" />
    <path d="M 462.1 887.7 A 3.5 3.5 0 1 0 462.1 894.7 A 3.5 3.5 0 1 0 462.1 887.7 Z" />
    <path d="M 365.8 861.9 A 3.5 3.5 0 1 0 365.8 868.9 A 3.5 3.5 0 1 0 365.8 861.9 Z" />
    <path d="M 279.5 812.1 A 3.5 3.5 0 1 0 279.5 819.1 A 3.5 3.5 0 1 0 279.5 812.1 Z" />
    <path d="M 208.9 741.5 A 3.5 3.5 0 1 0 208.9 748.5 A 3.5 3.5 0 1 0 208.9 741.5 Z" />
    <path d="M 159.1 655.2 A 3.5 3.5 0 1 0 159.1 662.2 A 3.5 3.5 0 1 0 159.1 655.2 Z" />
    <path d="M 133.3 558.9 A 3.5 3.5 0 1 0 133.3 565.9 A 3.5 3.5 0 1 0 133.3 558.9 Z" />
    <path d="M 133.3 459.1 A 3.5 3.5 0 1 0 133.3 466.1 A 3.5 3.5 0 1 0 133.3 459.1 Z" />
    <path d="M 159.1 362.8 A 3.5 3.5 0 1 0 159.1 369.8 A 3.5 3.5 0 1 0 159.1 362.8 Z" />
    <path d="M 208.9 276.5 A 3.5 3.5 0 1 0 208.9 283.5 A 3.5 3.5 0 1 0 208.9 276.5 Z" />
    <path d="M 279.5 205.9 A 3.5 3.5 0 1 0 279.5 212.9 A 3.5 3.5 0 1 0 279.5 205.9 Z" />
    <path d="M 365.8 156.1 A 3.5 3.5 0 1 0 365.8 163.1 A 3.5 3.5 0 1 0 365.8 156.1 Z" />
    <path d="M 462.1 130.3 A 3.5 3.5 0 1 0 462.1 137.3 A 3.5 3.5 0 1 0 462.1 130.3 Z" />
  </g>

  <!-- Inner Rings -->
  <g fill="none" stroke="#ffb21a">
    <path d="M 512 280 A 232 232 0 1 0 512 744 A 232 232 0 1 0 512 280 Z" stroke-width="4" />
    <path d="M 512 305 A 207 207 0 1 0 512 719 A 207 207 0 1 0 512 305 Z" stroke-width="3" />
    <path d="M 512 336 A 176 176 0 1 0 512 688 A 176 176 0 1 0 512 336 Z" stroke-width="5" />
  </g>

  <!-- 24 Radiant Spokes -->
  <g fill="none" stroke="#ffc52f" stroke-linecap="round">
    <line x1="512.0" y1="468.0" x2="512.0" y2="358.0" stroke-width="4" />
    <line x1="523.4" y1="469.5" x2="551.9" y2="363.2" stroke-width="4" />
    <line x1="534.0" y1="473.9" x2="589.0" y2="378.6" stroke-width="4" />
    <line x1="543.1" y1="480.9" x2="620.9" y2="403.1" stroke-width="4" />
    <line x1="550.1" y1="490.0" x2="645.4" y2="435.0" stroke-width="4" />
    <line x1="554.5" y1="500.6" x2="660.8" y2="472.1" stroke-width="4" />
    <line x1="556.0" y1="512.0" x2="666.0" y2="512.0" stroke-width="4" />
    <line x1="554.5" y1="523.4" x2="660.8" y2="551.9" stroke-width="4" />
    <line x1="550.1" y1="534.0" x2="645.4" y2="589.0" stroke-width="4" />
    <line x1="543.1" y1="543.1" x2="620.9" y2="620.9" stroke-width="4" />
    <line x1="534.0" y1="550.1" x2="589.0" y2="645.4" stroke-width="4" />
    <line x1="523.4" y1="554.5" x2="551.9" y2="660.8" stroke-width="4" />
    <line x1="512.0" y1="556.0" x2="512.0" y2="666.0" stroke-width="4" />
    <line x1="500.6" y1="554.5" x2="472.1" y2="660.8" stroke-width="4" />
    <line x1="490.0" y1="550.1" x2="435.0" y2="645.4" stroke-width="4" />
    <line x1="480.9" y1="543.1" x2="403.1" y2="620.9" stroke-width="4" />
    <line x1="473.9" y1="534.0" x2="378.6" y2="589.0" stroke-width="4" />
    <line x1="469.5" y1="523.4" x2="363.2" y2="551.9" stroke-width="4" />
    <line x1="468.0" y1="512.0" x2="358.0" y2="512.0" stroke-width="4" />
    <line x1="469.5" y1="500.6" x2="363.2" y2="472.1" stroke-width="4" />
    <line x1="473.9" y1="490.0" x2="378.6" y2="435.0" stroke-width="4" />
    <line x1="480.9" y1="480.9" x2="403.1" y2="403.1" stroke-width="4" />
    <line x1="490.0" y1="473.9" x2="435.0" y2="378.6" stroke-width="4" />
    <line x1="500.6" y1="469.5" x2="472.1" y2="363.2" stroke-width="4" />
  </g>

  <!-- 24-Polygon Core Wheel -->
  <g fill="none" stroke="#ffb01a" stroke-width="5">
    <polygon points="512.0,358.0 551.9,363.2 589.0,378.6 620.9,403.1 645.4,435.0 660.8,472.1 666.0,512.0 660.8,551.9 645.4,589.0 620.9,620.9 589.0,645.4 551.9,660.8 512.0,666.0 472.1,660.8 435.0,645.4 403.1,620.9 378.6,589.0 363.2,551.9 358.0,512.0 363.2,472.1 378.6,435.0 403.1,403.1 435.0,378.6 472.1,363.2" />
    <path d="M 512 359 A 153 153 0 1 0 512 665 A 153 153 0 1 0 512 359 Z" />
    <path d="M 512 445 A 67 67 0 1 0 512 579 A 67 67 0 1 0 512 445 Z" />
  </g>

  <path d="M 512 460 A 52 52 0 1 0 512 564 A 52 52 0 1 0 512 460 Z" fill="url(#core)" />
  <path d="M 512 485 A 27 27 0 1 0 512 539 A 27 27 0 1 0 512 485 Z" fill="#ffca32" stroke="#ffe889" stroke-width="4" />
  <path d="M 512 505 A 7 7 0 1 0 512 519 A 7 7 0 1 0 512 505 Z" fill="#fff2a0" />
</svg>""";

  static const String _dashedRingSvgData = r"""<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <g fill="none" stroke="#ffb01a" stroke-width="3.5" stroke-linecap="round">
    <path d="M526.4,98.3 A414,414 0 0 1 598.1,107.0" />
    <path d="M633.0,116.1 A414,414 0 0 1 700.0,143.1" />
    <path d="M731.4,160.9 A414,414 0 0 1 789.0,204.3" />
    <path d="M814.8,229.7 A414,414 0 0 1 859.2,286.5" />
    <path d="M877.5,317.6 A414,414 0 0 1 905.7,384.1" />
    <path d="M915.4,418.9 A414,414 0 0 1 925.4,490.3" />
    <path d="M925.7,526.4 A414,414 0 0 1 917.0,598.1" />
    <path d="M907.9,633.0 A414,414 0 0 1 880.9,700.0" />
    <path d="M863.1,731.4 A414,414 0 0 1 819.7,789.0" />
    <path d="M794.3,814.8 A414,414 0 0 1 737.5,859.2" />
    <path d="M706.4,877.5 A414,414 0 0 1 639.9,905.7" />
    <path d="M605.1,915.4 A414,414 0 0 1 533.7,925.4" />
    <path d="M497.6,925.7 A414,414 0 0 1 425.9,917.0" />
    <path d="M391.0,907.9 A414,414 0 0 1 324.0,880.9" />
    <path d="M292.6,863.1 A414,414 0 0 1 235.0,819.7" />
    <path d="M209.2,794.3 A414,414 0 0 1 164.8,737.5" />
    <path d="M146.5,706.4 A414,414 0 0 1 118.3,639.9" />
    <path d="M108.6,605.1 A414,414 0 0 1 98.6,533.7" />
    <path d="M98.3,497.6 A414,414 0 0 1 107.0,425.9" />
    <path d="M116.1,391.0 A414,414 0 0 1 143.1,324.0" />
    <path d="M160.9,292.6 A414,414 0 0 1 204.3,235.0" />
    <path d="M229.7,209.2 A414,414 0 0 1 286.5,164.8" />
    <path d="M317.6,146.5 A414,414 0 0 1 384.1,118.3" />
    <path d="M418.9,108.6 A414,414 0 0 1 490.3,98.6" />
  </g>
</svg>""";

  static const String _fireClockwiseSvgData = r"""<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <g fill="none" stroke-linejoin="round">
    <polygon points="512.0,206.0 728.4,295.6 818.0,512.0 728.4,728.4 512.0,818.0 295.6,728.4 206.0,512.0 295.6,295.6" stroke="#ff5a00" stroke-width="6" />
    <polygon points="629.1,229.3 794.7,394.9 794.7,629.1 629.1,794.7 394.9,794.7 229.3,629.1 229.3,394.9 394.9,229.3" stroke="#ff7a00" stroke-width="4" />
  </g>
</svg>""";

  static const String _fireAntiClockwiseSvgData = r"""<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <g fill="none" stroke-linejoin="round">
    <polygon points="512.0,226.0 714.2,309.8 798.0,512.0 714.2,714.2 512.0,798.0 309.8,714.2 226.0,512.0 309.8,309.8" stroke="#ff5a00" stroke-width="3" />
    <polygon points="563.7,252.1 659.2,291.7 732.3,364.8 771.9,460.3 771.9,563.7 732.3,659.2 659.2,732.3 563.7,771.9 460.3,771.9 364.8,732.3 291.7,659.2 252.1,563.7 252.1,460.3 291.7,364.8 364.8,291.7 460.3,252.1" stroke="#ffa500" stroke-width="4" />
  </g>
</svg>""";
}
