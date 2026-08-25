import 'package:flutter/material.dart';
import '../star_rain_1.dart';

/// The Universal Global Background.
/// Wraps the entire app in main.dart so the animation runs exactly ONCE
/// continuously, rather than stopping and starting on every screen.
class AppBackground extends StatelessWidget {
  final Widget child;
  
  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // 1. Base Dark Theme Color
        Container(
          color: const Color(0xFF050814),
        ),

        // 2. Continuous Stardust Rainfall Animation (Runs 1 time globally)
        const Positioned.fill(
          child: StarRain1(),
        ),

        // 3. Ambient Glow Layers
        Positioned(
          top: size.height * 0.10,
          left: size.width * 0.1,
          child: Container(
            width: size.width * 0.8,
            height: size.width * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00E5FF).withValues(alpha: 0.08),
                  const Color(0xFF6C63FF).withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // 4. The Active Screen (Transparent Scaffold)
        child,
      ],
    );
  }
}
