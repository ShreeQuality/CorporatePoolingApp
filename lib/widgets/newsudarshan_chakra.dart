import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Saved: Sacred Animated Sudarshan Chakra (newsudarshan_chakra)
/// Features:
///   - Optimized for Pristine White / Light Background (Rich Saffron, Royal Gold & Deep Amber Linework)
///   - Pure Physical Kinetic Vibration Tremor (NO flashing color/lighting changes during vibration)
///   - Constant Steady Aura & Non-Flashing Sacred Colors
///   - Exact 3D Inverted Perspective Ground Tilt (rotateX -54°, rotateZ 10°, 1.6x Zoom)
///   - Main Sacred Wheel & Solid Rings: Clockwise (8s)
///   - Dashed Circle Line (- - -) at Outer 4th Circle: Anti-Clockwise (6.5s)
///   - Outer Fire Stars: Clockwise (5.5s)
///   - Inner Fire Stars: Anti-Clockwise (4.5s)
class NewSudarshanChakra extends StatefulWidget {
  const NewSudarshanChakra({
    super.key,
    this.size = 170,
    this.speed = 1.0,
  });

  final double size;
  final double speed;

  @override
  State<NewSudarshanChakra> createState() => _NewSudarshanChakraState();
}

class _NewSudarshanChakraState extends State<NewSudarshanChakra>
    with TickerProviderStateMixin {
  late final AnimationController _wheelController;
  late final AnimationController _dashedRingController;
  late final AnimationController _fireClockwiseController;
  late final AnimationController _fireAntiClockwiseController;
  late final AnimationController _ambientGlowController;
  late final AnimationController _vibrationTremorController;

  @override
  void initState() {
    super.initState();

    // 1. Main Sacred Wheel spins CLOCKWISE (8000ms)
    _wheelController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (8000 / widget.speed).round()),
    )..repeat();

    // 2. Dashed Circle Line (- - -) at outer side of 4th circle spins ANTI-CLOCKWISE (6500ms)
    _dashedRingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (6500 / widget.speed).round()),
    )..repeat();

    // 3. Outer Fire Hexagon Star spins CLOCKWISE (5500ms)
    _fireClockwiseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (5500 / widget.speed).round()),
    )..repeat();

    // 4. Inner Fire Hexagon Star spins ANTI-CLOCKWISE (4500ms)
    _fireAntiClockwiseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (4500 / widget.speed).round()),
    )..repeat();

    // 5. Subtle Calm Breathing Pulse (2400ms)
    _ambientGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // 6. Periodic Sacred Vibration Tremor (3200ms)
    _vibrationTremorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _wheelController.dispose();
    _dashedRingController.dispose();
    _fireClockwiseController.dispose();
    _fireAntiClockwiseController.dispose();
    _ambientGlowController.dispose();
    _vibrationTremorController.dispose();
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
            _wheelController,
            _dashedRingController,
            _fireClockwiseController,
            _fireAntiClockwiseController,
            _ambientGlowController,
            _vibrationTremorController,
          ]),
          builder: (context, _) {
            final vibVal = _vibrationTremorController.value;
            double tremorX = 0.0;
            double tremorY = 0.0;

            if (vibVal > 0.75) {
              final progress = (vibVal - 0.75) / 0.25;
              final envelope = math.sin(progress * math.pi);
              tremorX = math.sin(progress * 10 * math.pi * 2) * 2.2 * envelope;
              tremorY = math.cos(progress * 10 * math.pi * 2) * 1.6 * envelope;
            }

            final baseGlow = _ambientGlowController.value;
            final glowScale = 1.62 + (baseGlow * 0.08);

            return Stack(
              alignment: Alignment.center,
              children: [
                // 1. Tilted 3D Soft Solar Ground Shadow & Golden Amber Aura (Optimized for White Theme)
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..translate(tremorX * 0.4, tremorY * 0.4, 0.0)
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
                          const Color(0xFFFF9500).withValues(alpha: 0.28),
                          const Color(0xFFFF6D00).withValues(alpha: 0.15),
                          const Color(0xFFE65100).withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.45, 0.75],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8F00).withValues(alpha: 0.25),
                          blurRadius: 35,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: const Color(0xFFD84315).withValues(alpha: 0.12),
                          blurRadius: 70,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. 3D Tilt Container with Micro-Tremor Displacement & 1.6x Zoom
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..translate(tremorX, tremorY, 0.0)
                    ..scale(1.60, 1.60, 1.0)
                    ..rotateX(-54 * math.pi / 180)
                    ..rotateZ(10 * math.pi / 180),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // LAYER 1: Main Sacred Wheel (Spins CLOCKWISE at 8s)
                      Transform.rotate(
                        angle: _wheelController.value * math.pi * 2,
                        child: SvgPicture.string(
                          _wheelWhiteThemeSvgData,
                          width: widget.size,
                          height: widget.size,
                        ),
                      ),

                      // LAYER 1B: Dashed Circle Line (- - -) (Spins ANTI-CLOCKWISE at 6.5s)
                      Transform.rotate(
                        angle: -_dashedRingController.value * math.pi * 2,
                        child: SvgPicture.string(
                          _dashedRingWhiteThemeSvgData,
                          width: widget.size,
                          height: widget.size,
                        ),
                      ),

                      // LAYER 2: Outer Fire Star Polygons (Spins CLOCKWISE at 5.5s)
                      Transform.rotate(
                        angle: _fireClockwiseController.value * math.pi * 2,
                        child: SvgPicture.string(
                          _fireClockwiseWhiteThemeSvgData,
                          width: widget.size,
                          height: widget.size,
                        ),
                      ),

                      // LAYER 3: Inner Fire Star Polygons (Spins ANTI-CLOCKWISE at 4.5s)
                      Transform.rotate(
                        angle: -_fireAntiClockwiseController.value * math.pi * 2,
                        child: SvgPicture.string(
                          _fireAntiClockwiseWhiteThemeSvgData,
                          width: widget.size,
                          height: widget.size,
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

  static const String _wheelWhiteThemeSvgData = r"""<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="whiteThemeCore" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#fff8e1" />
      <stop offset="35%" stop-color="#ffb300" />
      <stop offset="100%" stop-color="#e65100" stop-opacity="0" />
    </radialGradient>
  </defs>

  <path d="M 512 282 A 230 230 0 1 0 512 742 A 230 230 0 1 0 512 282 Z" fill="url(#whiteThemeCore)" opacity="0.35" />

  <g fill="none" stroke="#d84315">
    <path d="M 512 58 A 454 454 0 1 0 512 966 A 454 454 0 1 0 512 58 Z" stroke-width="2.5" stroke-opacity="0.9" />
    <path d="M 512 68 A 444 444 0 1 0 512 956 A 444 444 0 1 0 512 68 Z" stroke-width="4.5" stroke="#e65100" />
    <path d="M 512 86 A 426 426 0 1 0 512 938 A 426 426 0 1 0 512 86 Z" stroke-width="2" stroke="#f57c00" />
    <path d="M 512 107 A 405 405 0 1 0 512 917 A 405 405 0 1 0 512 107 Z" stroke-width="3.5" stroke="#ef6c00" />
    <path d="M 512 125 A 387 387 0 1 0 512 899 A 387 387 0 1 0 512 125 Z" stroke-width="2" stroke="#f57c00" />
    <path d="M 512 152 A 360 360 0 1 0 512 872 A 360 360 0 1 0 512 152 Z" stroke-width="4.5" stroke="#fb8c00" />
    <path d="M 512 170 A 342 342 0 1 0 512 854 A 342 342 0 1 0 512 170 Z" stroke-width="2.5" stroke="#f57c00" />
  </g>

  <g fill="#bf360c">
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

  <g fill="none" stroke="#d84315">
    <path d="M 512 280 A 232 232 0 1 0 512 744 A 232 232 0 1 0 512 280 Z" stroke-width="4.5" stroke="#bf360c" />
    <path d="M 512 305 A 207 207 0 1 0 512 719 A 207 207 0 1 0 512 305 Z" stroke-width="3" stroke="#e65100" />
    <path d="M 512 336 A 176 176 0 1 0 512 688 A 176 176 0 1 0 512 336 Z" stroke-width="5.5" stroke="#bf360c" />
  </g>

  <g fill="none" stroke="#e65100" stroke-linecap="round">
    <line x1="512.0" y1="468.0" x2="512.0" y2="358.0" stroke-width="4.5" />
    <line x1="523.4" y1="469.5" x2="551.9" y2="363.2" stroke-width="4.5" />
    <line x1="534.0" y1="473.9" x2="589.0" y2="378.6" stroke-width="4.5" />
    <line x1="543.1" y1="480.9" x2="620.9" y2="403.1" stroke-width="4.5" />
    <line x1="550.1" y1="490.0" x2="645.4" y2="435.0" stroke-width="4.5" />
    <line x1="554.5" y1="500.6" x2="660.8" y2="472.1" stroke-width="4.5" />
    <line x1="556.0" y1="512.0" x2="666.0" y2="512.0" stroke-width="4.5" />
    <line x1="554.5" y1="523.4" x2="660.8" y2="551.9" stroke-width="4.5" />
    <line x1="550.1" y1="534.0" x2="645.4" y2="589.0" stroke-width="4.5" />
    <line x1="543.1" y1="543.1" x2="620.9" y2="620.9" stroke-width="4.5" />
    <line x1="534.0" y1="550.1" x2="589.0" y2="645.4" stroke-width="4.5" />
    <line x1="523.4" y1="554.5" x2="551.9" y2="660.8" stroke-width="4.5" />
    <line x1="512.0" y1="556.0" x2="512.0" y2="666.0" stroke-width="4.5" />
    <line x1="500.6" y1="554.5" x2="472.1" y2="660.8" stroke-width="4.5" />
    <line x1="490.0" y1="550.1" x2="435.0" y2="645.4" stroke-width="4.5" />
    <line x1="480.9" y1="543.1" x2="403.1" y2="620.9" stroke-width="4.5" />
    <line x1="473.9" y1="534.0" x2="378.6" y2="589.0" stroke-width="4.5" />
    <line x1="469.5" y1="523.4" x2="363.2" y2="551.9" stroke-width="4.5" />
    <line x1="468.0" y1="512.0" x2="358.0" y2="512.0" stroke-width="4.5" />
    <line x1="469.5" y1="500.6" x2="363.2" y2="472.1" stroke-width="4.5" />
    <line x1="473.9" y1="490.0" x2="378.6" y2="435.0" stroke-width="4.5" />
    <line x1="480.9" y1="480.9" x2="403.1" y2="403.1" stroke-width="4.5" />
    <line x1="490.0" y1="473.9" x2="435.0" y2="378.6" stroke-width="4.5" />
    <line x1="500.6" y1="469.5" x2="472.1" y2="363.2" stroke-width="4.5" />
  </g>

  <g fill="none" stroke="#d84315" stroke-width="5.5">
    <polygon points="512.0,358.0 551.9,363.2 589.0,378.6 620.9,403.1 645.4,435.0 660.8,472.1 666.0,512.0 660.8,551.9 645.4,589.0 620.9,620.9 589.0,645.4 551.9,660.8 512.0,666.0 472.1,660.8 435.0,645.4 403.1,620.9 378.6,589.0 363.2,551.9 358.0,512.0 363.2,472.1 378.6,435.0 403.1,403.1 435.0,378.6 472.1,363.2" />
    <path d="M 512 359 A 153 153 0 1 0 512 665 A 153 153 0 1 0 512 359 Z" stroke="#e65100" />
    <path d="M 512 445 A 67 67 0 1 0 512 579 A 67 67 0 1 0 512 445 Z" stroke="#bf360c" stroke-width="4" />
  </g>

  <path d="M 512 460 A 52 52 0 1 0 512 564 A 52 52 0 1 0 512 460 Z" fill="url(#whiteThemeCore)" />
  <path d="M 512 485 A 27 27 0 1 0 512 539 A 27 27 0 1 0 512 485 Z" fill="#ffb300" stroke="#bf360c" stroke-width="4" />
  <path d="M 512 505 A 7 7 0 1 0 512 519 A 7 7 0 1 0 512 505 Z" fill="#bf360c" />
</svg>""";
  static const String _dashedRingWhiteThemeSvgData = r"""<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <g fill="none" stroke="#e65100" stroke-width="3.5" stroke-linecap="round">
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
  static const String _fireClockwiseWhiteThemeSvgData = r"""<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <g fill="none" stroke-linejoin="round">
    <polygon points="512.0,206.0 728.4,295.6 818.0,512.0 728.4,728.4 512.0,818.0 295.6,728.4 206.0,512.0 295.6,295.6" stroke="#c62828" stroke-width="6.5" />
    <polygon points="629.1,229.3 794.7,394.9 794.7,629.1 629.1,794.7 394.9,794.7 229.3,629.1 229.3,394.9 394.9,229.3" stroke="#e65100" stroke-width="4.5" />
  </g>
</svg>""";
  static const String _fireAntiClockwiseWhiteThemeSvgData = r"""<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <g fill="none" stroke-linejoin="round">
    <polygon points="512.0,226.0 714.2,309.8 798.0,512.0 714.2,714.2 512.0,798.0 309.8,714.2 226.0,512.0 309.8,309.8" stroke="#d84315" stroke-width="4" />
    <polygon points="563.7,252.1 659.2,291.7 732.3,364.8 771.9,460.3 771.9,563.7 732.3,659.2 659.2,732.3 563.7,771.9 460.3,771.9 364.8,732.3 291.7,659.2 252.1,563.7 252.1,460.3 291.7,364.8 364.8,291.7 460.3,252.1" stroke="#f57c00" stroke-width="5" />
  </g>
</svg>""";
}
