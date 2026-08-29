import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/wallet_provider.dart';

// ═════════════════════════════════════════════════════════════
// Karma Coins Card — exact color/glow match to reference image
// ═════════════════════════════════════════════════════════════
//
// What's happening visually in the reference:
//   1. BASE: near-black navy background (#0A121C)
//   2. FOG: a warm amber/gold radial glow bleeding in from the
//      TOP-LEFT corner only, fading into the dark base — this is
//      what gives the "Karma Coins" label + coin its warm glow.
//   3. BORDER: a thin gradient outline — gold at top-left,
//      sweeping through teal, ending cyan-blue at bottom-right.
//   4. Each stat has its OWN glow color: gold (coins), cyan
//      (pill, filled solid + glowing), green (CO2), red (trust).
// ─────────────────────────────────────────────────────────────

class KarmaCardColors {
  static const bgBase      = Color(0xFF28363D); // measured true base — muted slate, not near-black
  static const fogAmber    = Color(0xFFFFB300); // top-left warm glow source
  static const fogCyan     = Color(0xFF265062); // measured interior glow peak color

  // Border gradient sweep: gold → teal → cyan-blue
  static const borderGold  = Color(0xFFFFD65C);
  static const borderTeal  = Color(0xFF33C7C1);
  static const borderCyan  = Color(0xFF2E9BE6);

  static const coinGoldHi  = Color(0xFFFFDB70); // coin circle highlight
  static const coinGoldLo  = Color(0xFFE8A317); // coin circle shadow edge
  static const textCoinTitle = Color(0xFFFFE9B0); // "340 Coins" warm cream
  static const textLabel   = Color(0xFFF3D9A4); // "Karma Coins" label

  static const pillCyanFill = Color(0xFF19C9E6); // solid glowing pill bg
  static const pillCyanText = Color(0xFF07222C); // dark text on pill

  static const co2Green     = Color(0xFF3FE07E);
  static const co2GreenMuted= Color(0xFF7FA893);

  static const trustRed     = Color(0xFFFF5B5B);
  static const trustRedMuted= Color(0xFF9E8080);
}

// ═════════════════════════════════════════════════════════════
// GRAIN / NOISE OVERLAY
// ═════════════════════════════════════════════════════════════
//
// Thousands of tiny random black/white dots at very low opacity.
// Uses a FIXED random seed so the pattern is stable (doesn't
// shimmer/flicker on rebuild) and shouldRepaint = false so it's
// painted once and cached — effectively free performance cost.
// ─────────────────────────────────────────────────────────────

class GrainOverlay extends StatelessWidget {
  /// Overall strength of the grain. Real premium UIs sit around
  /// 0.04–0.08 — anything higher starts looking like visible static.
  final double opacity;

  /// Roughly how many dots per 1000px² of surface area.
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
  // Fixed seed → same grain pattern every time, no flicker.
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
      final strength = _rng.nextDouble() * 0.5 + 0.2; // 0.2–0.7
      paint.color =
          (isLight ? Colors.white : Colors.black).withOpacity(strength);
      canvas.drawRect(Rect.fromLTWH(x, y, 1.0, 1.0), paint);
    }
  }

  // Static grain — never needs to repaint once drawn.
  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => false;
}


// ═════════════════════════════════════════════════════════════
// EDGE-GLOW BORDER — the border's light "bleeding" onto the
// interior surface (this is the piece that was missing).
// ═════════════════════════════════════════════════════════════
//
// A real glowing border is TWO strokes on the same path:
//   1. A wide, heavily blurred stroke   → the soft bleed/glow
//   2. A thin, crisp stroke on top      → the visible hairline
// Both use the SAME gradient, so the glow color matches the
// border color at every point — warm gold near top-left,
// cooling to teal/cyan near top-right and the right edge.
// ─────────────────────────────────────────────────────────────

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

    // Same diagonal sweep as the visible border (topLeft -> bottomRight)
    final shader = ui.Gradient.linear(
      Offset.zero,
      Offset(size.width, size.height),
      colors,
      stops,
    );

    // 1. Wide blurred stroke = the glow that bleeds onto the interior
    final glowPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlurSigma);
    canvas.drawRRect(rrect, glowPaint);

    // 2. Thin crisp stroke = the visible hairline on top
    final linePaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;
    canvas.drawRRect(rrect, linePaint);
  }

  // Static — draw once, never repaint.
  @override
  bool shouldRepaint(covariant _EdgeGlowPainter oldDelegate) => false;
}


// ═════════════════════════════════════════════════════════════
// INTERIOR GLOW — CustomPainter, built from measured pixel data
// ═════════════════════════════════════════════════════════════
//
// Not a Container/BoxShadow guess — these values came from
// sampling the actual reference image pixel-by-pixel:
//   • Cyan glow peak sits at ~80% across, ~15% down (inset from
//     the corner, not sitting on it), color ≈ #265062
//   • True base color (far corner) ≈ #28363D — a muted slate,
//     NOT near-black
//   • Falloff reaches ~66% of width / ~70% of height before
//     hitting base color
//
// Technique: draw a RADIAL gradient with ui.Gradient.radial,
// then squash the canvas on one axis before painting it. A
// perfect circle, painted onto a non-uniformly scaled canvas,
// becomes a true ellipse — with independently controllable X/Y
// radii. This is the correct way to get an elliptical gradient;
// BoxDecoration's RadialGradient cannot do this precisely.
// ─────────────────────────────────────────────────────────────

class InteriorGlowPainter extends CustomPainter {
  /// Where the glow peaks, in Alignment space (-1..1 on each axis).
  final Alignment position;
  final Color peakColor;
  final Color baseColor;
  /// How far the glow reaches, as a fraction of the canvas width/height.
  final double radiusXFactor;
  final double radiusYFactor;

  InteriorGlowPainter({
    required this.position,
    required this.peakColor,
    required this.baseColor,
    required this.radiusXFactor,
    required this.radiusYFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = position.alongSize(size);
    final radiusX = size.width * radiusXFactor;
    final radiusY = size.height * radiusYFactor;
    final squash = radiusY / radiusX;

    canvas.save();
    // Squash canvas vertically around the glow's own center, so a
    // circular gradient renders as an ellipse matching the measured
    // horizontal vs vertical falloff.
    canvas.translate(center.dx, center.dy);
    canvas.scale(1.0, squash);
    canvas.translate(-center.dx, -center.dy);

    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radiusX,
        [peakColor, baseColor],
        const [0.0, 1.0],
      );

    // Oversized rect so the squashed paint still fully covers the
    // canvas after the inverse-scale is applied on restore.
    canvas.drawRect(
      Rect.fromCircle(center: center, radius: radiusX * 3),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant InteriorGlowPainter oldDelegate) => false;
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: KarmaCardColors.bgBase.withOpacity(0.45), // Translucent base to show rainfall
        child: Stack(
          children: [
            // ── INTERIOR GLOW (cyan): CustomPainter, elliptical
            // radial gradient fitted to measured pixel data.
            // Peak sits at 80% across / 15% down — NOT at the
            // literal corner — fading to transparent so the rainfall shows through.
            Positioned.fill(
              child: CustomPaint(
                painter: InteriorGlowPainter(
                  position: const Alignment(0.60, -0.70), // 80%,15% -> alignment space
                  peakColor: KarmaCardColors.fogCyan.withOpacity(0.7), // Semi-transparent peak
                  baseColor: Colors.transparent, // Fade to transparent, not opaque base
                  radiusXFactor: 0.66,
                  radiusYFactor: 0.70,
                ),
              ),
            ),

            // ── INTERIOR GLOW (amber): same technique, centered
            // near the coin icon on the left rather than the
            // exact top-left corner point. Fades to TRANSPARENT
            // (not bgBase) since this paints on top of the cyan
            // layer — using an opaque outer color here would
            // erase the cyan glow underneath everywhere it covers.
            Positioned.fill(
              child: CustomPaint(
                painter: InteriorGlowPainter(
                  position: const Alignment(-0.84, -0.10), // ~8%,45% -> alignment space
                  peakColor: const Color(0xCC6E5A2E), // ~80% opacity, blends instead of replacing
                  baseColor: Colors.transparent,
                  radiusXFactor: 0.60,
                  radiusYFactor: 0.62,
                ),
              ),
            ),

            // ── TOP EDGE HIGHLIGHT: a separate thin white sheen
            // strip along the very top of the card — a different
            // SHAPE entirely (a band, not a circle). Simulates
            // glass catching overhead light.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 46,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x14FFFFFF), // ~8% white
                      Color(0x00FFFFFF),
                    ],
                  ),
                ),
              ),
            ),

            // ── BORDER STROKE
            // Uses the EdgeGlowBorder class but with glowWidth: 0
            // so we just get the crisp 1.4px gradient line without
            // the heavy "rectangle-wise" glow you disliked earlier.
            // This replaces the old "opaque container padding" hack,
            // allowing true transparency for the rainfall.
            const Positioned.fill(
              child: EdgeGlowBorder(
                borderRadius: 20,
                lineWidth: 1.4,
                glowWidth: 0, // No glow, just the stroke
              ),
            ),

            // ── GRAIN: subtle noise texture over the whole card,
            // sits above the fog glow, below the text/icons.
            const Positioned.fill(
              child: GrainOverlay(opacity: 0.06, density: 7),
            ),

            // ── CONTENT
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: sparkle + "Karma Coins" label
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 15, color: KarmaCardColors.textLabel),
                          const SizedBox(width: 6),
                          Text(
                            'Karma Coins',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: KarmaCardColors.textLabel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Row 2: coin icon + big glowing count
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Coin circle with gold gradient + glow
                          Container(
                            width: 30,
                            height: 30,
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
                                BoxShadow(
                                  color: KarmaCardColors.fogAmber
                                      .withOpacity(0.6),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text('K',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: Color(0xFF3A2600),
                                )),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$coins',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: KarmaCardColors.textCoinTitle,
                              shadows: [
                                Shadow(
                                  color: KarmaCardColors.fogAmber
                                      .withOpacity(0.55),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Coins',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: KarmaCardColors.textCoinTitle
                                    .withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Row 3: grant pill + CO2 + trust score
                      Row(
                        children: [
                          // Solid glowing cyan pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: KarmaCardColors.pillCyanFill,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: KarmaCardColors.pillCyanFill
                                      .withOpacity(0.55),
                                  blurRadius: 14,
                                  spreadRadius: 0.5,
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: KarmaCardColors.pillCyanText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // CO2 saved
                          _StatItem(
                            icon: Icons.cloud_upload_outlined,
                            iconColor: KarmaCardColors.co2Green,
                            valueText: '${co2SavedKg}kg',
                            valueColor: KarmaCardColors.co2Green,
                            labelText: 'CO2 Saved',
                            labelColor: KarmaCardColors.co2GreenMuted,
                          ),
                          const SizedBox(width: 16),

                          // Trust score
                          _StatItem(
                            icon: Icons.verified_user_outlined,
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
      ),
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
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              valueText,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: valueColor,
              ),
            ),
            Text(
              labelText,
              style: TextStyle(
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
