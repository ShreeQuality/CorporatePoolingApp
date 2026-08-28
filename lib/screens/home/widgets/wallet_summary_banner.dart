import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/wallet_provider.dart';

class WalletSummaryBanner extends StatelessWidget {
  const WalletSummaryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProv, child) {
        final summary = walletProv.summary;

        return CustomPaint(
          painter: _KarmaCardGlowPainter(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1726).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Sparkle + "Karma Coins"
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFFFE082),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Karma Coins',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFFE082),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Main Coin Row: 3D Embossed (K) Medallion + "340 Coins"
                Row(
                  children: [
                    // Coin with Golden Radial Energy Bloom
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB300).withValues(alpha: 0.75),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: const Color(0xFFFFE082).withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                        gradient: const RadialGradient(
                          center: Alignment(-0.35, -0.4),
                          radius: 0.85,
                          colors: [
                            Color(0xFFFFF9C4), // Bright highlight
                            Color(0xFFFFD54F), // Gold body
                            Color(0xFFFF8F00), // Deep rim
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFFFFDE7),
                          width: 1.6,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'K',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF3E2723),
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${summary.availableCoins.toStringAsFixed(0)} Coins',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFE082),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: const Color(0xFFFFB300).withValues(alpha: 0.7),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Bottom Row: 1. Solid Glowing Cyan Pill + 2. Green Cloud Metric + 3. Red Shield Metric
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Solid Glowing Cyan Pill (200 Grant Left)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: const Color(0xFF80D8FF).withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF00384D),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${summary.corporateGrantRemaining.toStringAsFixed(0)} Grant Left',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF002A3A),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. CO2 Metric (Green Cloud + Stacked Text)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00E676).withValues(alpha: 0.22),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E676).withValues(alpha: 0.6),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.cloud_upload_rounded,
                            color: Color(0xFF00E676),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${summary.co2SavedKg.toStringAsFixed(1)} kg',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF00E676),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF00E676).withValues(alpha: 0.6),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'CO₂ Saved',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFCFD8DC),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // 3. Trust Score Metric (Red Shield + Stacked Text)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFF5252).withValues(alpha: 0.22),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF5252).withValues(alpha: 0.6),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: Color(0xFFFF5252),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${summary.trustScore.toStringAsFixed(0)}/100',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFF6E6E),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFFFF5252).withValues(alpha: 0.6),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Trust Score',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFCFD8DC),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// CustomPainter for the dual-tone neon glowing border
class _KarmaCardGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    // 1. Dual-tone Gradient Shader (Amber on Left/Bottom, Cyan on Right/Top)
    final gradientShader = const LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color(0xFFFFB74D), // Amber gold
        Color(0xFFFFD54F),
        Color(0xFF80D8FF),
        Color(0xFF00E5FF), // Electric cyan
      ],
      stops: [0.0, 0.35, 0.70, 1.0],
    ).createShader(rect);

    // 2. Outer Soft Neon Blur Halo
    final haloPaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    canvas.drawRRect(rrect, haloPaint);

    // 3. Crisp Inner Neon Line
    final borderPaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
