import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/wallet_provider.dart';

// ═════════════════════════════════════════════════════════════
// Karma Coins Card — Exact multi-layered glow structure
// ═════════════════════════════════════════════════════════════

class KarmaCardColors {
  static const bgBase = Color(0xFF0A121C); // near-black navy base
  static const fogAmber = Color(0xFFFFB300); // top-left warm glow source
  static const fogCyan = Color(0xFF33C7C1); // top-right cool glow source

  // Border gradient sweep: gold → teal → cyan-blue
  static const borderGold = Color(0xFFFFD65C);
  static const borderTeal = Color(0xFF33C7C1);
  static const borderCyan = Color(0xFF2E9BE6);

  static const coinGoldHi = Color(0xFFFFDB70); // coin circle highlight
  static const coinGoldLo = Color(0xFFE8A317); // coin circle shadow edge
  static const textCoinTitle = Color(0xFFFFE9B0); // "340 Coins" warm cream
  static const textLabel = Color(0xFFF3D9A4); // "Karma Coins" label

  static const pillCyanFill = Color(0xFF19C9E6); // solid glowing pill bg
  static const pillCyanText = Color(0xFF07222C); // dark text on pill

  static const co2Green = Color(0xFF3FE07E);
  static const co2GreenMuted = Color(0xFF7FA893);

  static const trustRed = Color(0xFFFF5B5B);
  static const trustRedMuted = Color(0xFF9E8080);
}

// ═════════════════════════════════════════════════════════════
// GRAIN / NOISE OVERLAY
// ═════════════════════════════════════════════════════════════

class GrainOverlay extends StatelessWidget {
  final double opacity;
  final int density;

  const GrainOverlay({
    super.key,
    this.opacity = 0.06,
    this.density = 7,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: _GrainPainter(density: density),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final int density;
  static final math.Random _rng = math.Random(1337);

  _GrainPainter({required this.density});

  @override
  void paint(Canvas canvas, Size size) {
    final count = (size.width * size.height / 1000 * density).round();
    final paint = Paint();

    for (int i = 0; i < count; i++) {
      final x = _rng.nextDouble() * size.width;
      final y = _rng.nextDouble() * size.height;
      final isLight = _rng.nextBool();
      final strength = _rng.nextDouble() * 0.5 + 0.2;
      paint.color =
          (isLight ? Colors.white : Colors.black).withValues(alpha: strength);
      canvas.drawRect(Rect.fromLTWH(x, y, 1.0, 1.0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => false;
}

// ═════════════════════════════════════════════════════════════
// EDGE-GLOW BORDER (Capable of bleeding OUTSIDE the card)
// ═════════════════════════════════════════════════════════════

class EdgeGlowBorder extends StatelessWidget {
  final double borderRadius;
  final double lineWidth;
  final double glowWidth;
  final double glowBlurSigma;
  final List<Color> colors;
  final List<double> stops;

  const EdgeGlowBorder({
    super.key,
    this.borderRadius = 19,
    this.lineWidth = 1.2,
    this.glowWidth = 7.0,
    this.glowBlurSigma = 6.0,
    this.colors = const [
      KarmaCardColors.borderGold,
      KarmaCardColors.borderTeal,
      KarmaCardColors.borderCyan,
    ],
    this.stops = const [0.0, 0.5, 1.0],
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _EdgeGlowPainter(
          borderRadius: borderRadius,
          lineWidth: lineWidth,
          glowWidth: glowWidth,
          glowBlurSigma: glowBlurSigma,
          colors: colors,
          stops: stops,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _EdgeGlowPainter extends CustomPainter {
  final double borderRadius;
  final double lineWidth;
  final double glowWidth;
  final double glowBlurSigma;
  final List<Color> colors;
  final List<double> stops;

  _EdgeGlowPainter({
    required this.borderRadius,
    required this.lineWidth,
    required this.glowWidth,
    required this.glowBlurSigma,
    required this.colors,
    required this.stops,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final shader = ui.Gradient.linear(
      Offset.zero,
      Offset(size.width, size.height),
      colors,
      stops,
    );

    // If glow width is > 0, paint the blurred mask
    if (glowWidth > 0) {
      final glowPaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = glowWidth
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlurSigma);
      canvas.drawRRect(rrect, glowPaint);
    }

    // If line width is > 0, paint the crisp inner edge
    if (lineWidth > 0) {
      final linePaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth;
      canvas.drawRRect(rrect, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EdgeGlowPainter oldDelegate) => false;
}

// ═════════════════════════════════════════════════════════════
// WALLET SUMMARY BANNER (Connected to Live WalletProvider)
// ═════════════════════════════════════════════════════════════

class WalletSummaryBanner extends StatelessWidget {
  const WalletSummaryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProv, child) {
        final summary = walletProv.summary;

        return KarmaCoinsCard(
          coins: summary.availableCoins.toInt(),
          grantLeft: summary.corporateGrantRemaining.toInt(),
          co2SavedKg: summary.co2SavedKg,
          trustScore: summary.trustScore.toInt(),
        );
      },
    );
  }
}

class KarmaCoinsCard extends StatelessWidget {
  final int coins;
  final int grantLeft;
  final double co2SavedKg;
  final int trustScore;

  const KarmaCoinsCard({
    super.key,
    this.coins = 340,
    this.grantLeft = 200,
    this.co2SavedKg = 18.8,
    this.trustScore = 98,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      // CRITICAL: Clip.none allows the EdgeGlowBorder's blur to radiate
      // out of the container onto the dark background!
      clipBehavior: Clip.none,
      children: [
        // ── 1. OUTER EDGE GLOW (Bleeding outside the card) ──
        const Positioned.fill(
          child: EdgeGlowBorder(
            borderRadius: 20,
            lineWidth: 0, // No crisp line here, just pure neon blur
            glowWidth: 10.0,
            glowBlurSigma: 8.0,
          ),
        ),

        // ── 2. MAIN CARD CONTENTS (Clipped internally) ──
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: KarmaCardColors.bgBase,
            child: Stack(
              children: [
                // ── FOG LAYER (Amber, top-left) ──
                Positioned(
                  top: -40,
                  left: -40,
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 45, sigmaY: 45),
                    child: Container(
                      width: 220,
                      height: 180,
                      decoration: BoxDecoration(
                        color: KarmaCardColors.fogAmber.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // ── FOG LAYER (Cyan, top-right) ──
                Positioned(
                  top: -30,
                  right: -30,
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      width: 180,
                      height: 150,
                      decoration: BoxDecoration(
                        color: KarmaCardColors.fogCyan.withValues(alpha: 0.28),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // ── TOP EDGE HIGHLIGHT (Sheen band) ──
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x1AFFFFFF), // ~10% white
                          Color(0x00FFFFFF),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── GRAIN: Subtle noise texture over fog ──
                const Positioned.fill(
                  child: GrainOverlay(opacity: 0.06, density: 7),
                ),

                // ── CONTENT ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Sparkle + "Karma Coins" label
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 15, color: KarmaCardColors.textLabel),
                          const SizedBox(width: 6),
                          Text(
                            'Karma Coins',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: KarmaCardColors.textLabel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Row 2: Coin icon + big glowing count
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 3D Coin Circle with gold gradient + immense glow
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  KarmaCardColors.coinGoldHi,
                                  KarmaCardColors.coinGoldLo,
                                ],
                              ),
                              boxShadow: [
                                // Outer radial glow
                                BoxShadow(
                                  color: KarmaCardColors.fogAmber
                                      .withValues(alpha: 0.75),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                                // Inner core glow
                                BoxShadow(
                                  color: KarmaCardColors.coinGoldHi
                                      .withValues(alpha: 0.5),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text('K',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: Color(0xFF3A2600),
                                )),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$coins',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: KarmaCardColors.textCoinTitle,
                              shadows: [
                                Shadow(
                                  color: KarmaCardColors.fogAmber
                                      .withValues(alpha: 0.8),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Coins',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: KarmaCardColors.textCoinTitle
                                    .withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row 3: Grant pill + CO2 + Trust score
                      Row(
                        children: [
                          // Solid glowing cyan pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: KarmaCardColors.pillCyanFill,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: KarmaCardColors.pillCyanFill
                                      .withValues(alpha: 0.8),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time,
                                    size: 15,
                                    color: KarmaCardColors.pillCyanText),
                                const SizedBox(width: 5),
                                Text(
                                  '$grantLeft Grant Left',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: KarmaCardColors.pillCyanText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),

                          // CO2 saved
                          _StatItem(
                            icon: Icons.cloud_upload_rounded,
                            iconColor: KarmaCardColors.co2Green,
                            valueText: '${co2SavedKg.toStringAsFixed(1)}kg',
                            valueColor: KarmaCardColors.co2Green,
                            labelText: 'CO2 Saved',
                            labelColor: KarmaCardColors.co2GreenMuted,
                          ),
                          const SizedBox(width: 20),

                          // Trust score
                          _StatItem(
                            icon: Icons.verified_user_rounded,
                            iconColor: KarmaCardColors.trustRed,
                            valueText: '$trustScore/100',
                            valueColor: KarmaCardColors.trustRed,
                            labelText: 'Trust Score',
                            labelColor: KarmaCardColors.trustRedMuted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── 3. CRISP INNER BORDER (Over everything) ──
        const Positioned.fill(
          child: IgnorePointer(
            child: EdgeGlowBorder(
              borderRadius: 20,
              lineWidth: 1.5,
              glowWidth: 0, // No glow, just the hairline border
              glowBlurSigma: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String valueText;
  final Color valueColor;
  final String labelText;
  final Color labelColor;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.valueText,
    required this.valueColor,
    required this.labelText,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.65),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              valueText,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: valueColor,
                shadows: [
                  Shadow(
                    color: valueColor.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            Text(
              labelText,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
