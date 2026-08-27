import 'package:flutter/material.dart';
import '../star_rain_1.dart';

/// The Universal Global Background.
/// Wraps the entire app in main.dart so the animation runs exactly ONCE
/// continuously, rather than stopping and starting on every screen.
class AppBackground extends StatelessWidget {
  final Widget child;
  
  /// Global dynamic exclusion zone (e.g. for Sacred Chakra on splash screen)
  static final ValueNotifier<Rect?> exclusionZone = ValueNotifier<Rect?>(null);
  
  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base Dark Theme Color (deep pitch black - no ambient glow)
        Container(
          color: const Color(0xFF020510),
        ),

        // 2. Continuous Stardust Rainfall Animation (Runs 1 time globally)
        Positioned.fill(
          child: ValueListenableBuilder<Rect?>(
            valueListenable: exclusionZone,
            builder: (context, zone, _) {
              return StarRain1(exclusionZone: zone);
            },
          ),
        ),

        // 3. The Active Screen (Transparent Scaffold)
        child,
      ],
    );
  }
}
