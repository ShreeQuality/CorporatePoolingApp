import 'dart:ui';
import 'package:flutter/material.dart';

/// A universal Glassmorphism container.
/// As per the SRS styling requirements, this standardizes the frosted glass
/// effect across the app. If performance issues arise on low-end devices,
/// we can globally reduce the `sigma` or toggle off the BackdropFilter here.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double sigma;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? customBorder;

  const GlassPanel({
    super.key,
    required this.child,
    this.sigma = 8.0, // Reduced from 12 to 8 for better performance
    this.opacity = 0.05,
    this.padding,
    this.margin,
    this.borderRadius,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);

    Widget container = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: radius,
        border: customBorder ?? Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: child,
    );

    // Using BackdropFilter is expensive. By centralizing it, 
    // a super admin config can dynamically return just the container
    // if a "battery saver" or "performance" mode is active.
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: container,
      ),
    );
  }
}
