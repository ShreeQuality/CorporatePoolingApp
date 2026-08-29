import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/wallet_provider.dart';

// ═════════════════════════════════════════════════════════════
// Karma Coins Card — color/glow match to reference image
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

class KarmaCardColors {
  static const bgBase      = Color(0xFF28363D); // measured true base — muted slate, not near-black
  static const fogAmber    = Color(0xFFFFB300); // top-left warm glow source
  static const fogCyan     = Color(0xFF265062); // measured interior glow peak color

  // Border gradient sweep — measured from the reference border
  static const borderGold  = Color(0xFFB2A27B);
  static const borderTeal  = Color(0xFF6E7F86);
  static const borderCyan  = Color(0xFF67B4C7);

  static const coinGoldHi  = Color(0xFFFFDB70); // coin circle highlight
  static const coinGoldLo  = Color(0xFFF0C24A); // coin circle shadow edge — measured range
  static const textCoinTitle = Color(0xFFFFE9B0); // "340 Coins" — measured #FFEAA1, near match
  static const textLabel   = Color(0xFFF3D9A4); // "Karma Coins" label — UNVERIFIED, sampling kept missing glyphs

  // Pill is NOT a flat fill — measured a top-to-bottom gradient.
  static const pillCyanHi   = Color(0xFF47E1F3); // measured, top of pill
  static const pillCyanLo   = Color(0xFF4DC9D9); // measured, bottom of pill
  static const pillCyanText = Color(0xFF07222C); // dark text on pill

  static const co2Green     = Color(0xFF3FE07E);
  static const co2GreenMuted= Color(0xFF7FA893);

  static const trustRed     = Color(0xFFFF5B5B);
  static const trustRedMuted= Color(0xFF9E8080);
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
          (isLight ? Colors.white : Colors.black).withOpacity(strength);
      canvas.drawRect(Rect.fromLTWH(x, y, 1.0, 1.0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => false;
}

// ═════════════════════════════════════════════════════════════
// EDGE-GLOW BORDER
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

    final glowPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlurSigma);
    canvas.drawRRect(rrect, glowPaint);

    final linePaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;
    canvas.drawRRect(rrect, linePaint);
  }

  @override
  bool shouldRepaint(covariant _EdgeGlowPainter oldDelegate) => false;
}

// ═════════════════════════════════════════════════════════════
// INTERIOR GLOW
// ═════════════════════════════════════════════════════════════

class InteriorGlowPainter extends CustomPainter {
  final Alignment position;
  final Color peakColor;
  final Color baseColor;
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

    canvas.drawRect(
      Rect.fromCircle(center: center, radius: radiusX * 3),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant InteriorGlowPainter oldDelegate) => false;
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
        padding: const EdgeInsets.all(1.4),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              KarmaCardColors.borderGold,
              KarmaCardColors.borderTeal,
              KarmaCardColors.borderCyan,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Container(
            color: KarmaCardColors.bgBase,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: InteriorGlowPainter(
                      position: const Alignment(0.60, -0.70),
                      peakColor: KarmaCardColors.fogCyan,
                      baseColor: KarmaCardColors.bgBase,
                      radiusXFactor: 0.66,
                      radiusYFactor: 0.70,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: InteriorGlowPainter(
                      position: const Alignment(-0.84, -0.10),
                      peakColor: const Color(0xCC6E5A2E),
                      baseColor: Colors.transparent,
                      radiusXFactor: 0.60,
                      radiusYFactor: 0.62,
                    ),
                  ),
                ),
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
                          Color(0x14FFFFFF),
                          Color(0x00FFFFFF),
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned.fill(
                  child: GrainOverlay(opacity: 0.06, density: 7),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  KarmaCardColors.pillCyanHi,
                                  KarmaCardColors.pillCyanLo,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: KarmaCardColors.pillCyanHi
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
                          _StatItem(
                            icon: Icons.cloud_upload_outlined,
                            iconColor: KarmaCardColors.co2Green,
                            valueText: '${co2SavedKg}kg',
                            valueColor: KarmaCardColors.co2Green,
                            labelText: 'CO2 Saved',
                            labelColor: KarmaCardColors.co2GreenMuted,
                          ),
                          const SizedBox(width: 16),
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
