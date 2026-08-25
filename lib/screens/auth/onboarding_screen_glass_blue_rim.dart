import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/secure_storage_service.dart';

/// Screen 2: Onboarding Carousel Screen
/// Featuring 100% Fully Transparent Cards (Zero Blur, Crisp Star Visibility)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _beamController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _dialController;

  final List<StitchBeamCardData> _cards = const [
    StitchBeamCardData(
      badgeText: '99.8% Trust Score',
      icon: Icons.shield_rounded,
      headline: 'Verified Colleagues,\nZero Strangers',
      description:
          'Ride exclusively with verified employees from tech parks & corporate campuses. Protected by multi-tier Aadhaar KYC, work email, and live safety radar.',
      chips: [
        'ðŸ”’ Work Email Verified',
        'ðŸ¢ Tech Park Network',
        'ðŸš¨ Live SOS Radar',
      ],
      themeColor: Color(0xFFFFB800),
      beamColors: [
        Color(0x00FF5722),
        Color(0xE6FF5722),
        Color(0xFFFF7A00),
        Color(0xFFFFB800),
        Color(0xFFFFF9C4),
        Color(0xFFFFB800),
        Color(0xFFFF7A00),
        Color(0xE6FF5722),
        Color(0x00FF5722),
      ],
      beamStops: [0.0, 0.05, 0.15, 0.30, 0.45, 0.60, 0.70, 0.80, 1.0],
      innerGlowColor: Color(0xFFFF9D00),
    ),
    StitchBeamCardData(
      badgeText: 'Zero-Detour Engine',
      icon: Icons.route_rounded,
      headline: 'Smart Route Matching,\nCashless Economy',
      description:
          'Sub-second 2-tier spatial engine pairs you along your exact commute corridor with zero-cellular BLE handshakes and dynamic boarding words.',
      chips: [
        'âš¡ Sub-Second Match',
        'ðŸ“¡ Offline BLE Boarding',
        'ðŸª™ Cashless Karma Coins',
      ],
      themeColor: Color(0xFFA855F7),
      beamColors: [
        Color(0x0000F5D4),
        Color(0xFF00F5D4),
        Color(0xFF38BDF8),
        Color(0xFF818CF8),
        Color(0xFFA855F7),
        Color(0xFFE9D5FF),
        Color(0xFFA855F7),
        Color(0xFF818CF8),
        Color(0x00A855F7),
      ],
      beamStops: [0.0, 0.05, 0.15, 0.30, 0.45, 0.60, 0.70, 0.80, 1.0],
      innerGlowColor: Color(0xFF6366F1),
    ),
    StitchBeamCardData(
      badgeText: '+1.88 kg COâ‚‚ Saved',
      icon: Icons.eco_rounded,
      headline: 'Earn Fuel Vouchers,\nDrive Net-Zero',
      description:
          'Convert your Karma Coins into digital fuel vouchers across HPCL, BPCL, and IOCL pumps while earning verified corporate ESG carbon offset badges.',
      chips: [
        'â›½ 30,000+ Fuel Pumps',
        'ðŸŒ± Verified ESG Offsets',
        'ðŸ† Green Leaderboards',
      ],
      themeColor: Color(0xFF00E676),
      beamColors: [
        Color(0x00059669),
        Color(0xFF059669),
        Color(0xFF10B981),
        Color(0xFF00E676),
        Color(0xFFDCFCE7),
        Color(0xFF00E676),
        Color(0xFF10B981),
        Color(0xFF059669),
        Color(0x0000E676),
      ],
      beamStops: [0.0, 0.05, 0.15, 0.30, 0.45, 0.60, 0.70, 0.80, 1.0],
      innerGlowColor: Color(0xFF00E676),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _beamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.90, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _dialController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _beamController.dispose();
    _pulseController.dispose();
    _dialController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    await SecureStorageService.setOnboardingSeen(true);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Welcome to KarmaRide! Routing to Authentication...'),
        backgroundColor: Color(0xFF0F172A),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _cards.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _cards[_currentPage];

    return Scaffold(
      backgroundColor: const Color(0xFF040711),
      body: Stack(
        children: [
          // â”€â”€â”€ [RAIN 1]: LINEAR VERTICAL COSMIC STARDUST RAINFALL â”€â”€â”€â”€
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131826).withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF1E293B),
                                width: 1.0,
                              ),
                            ),
                            child: Icon(
                              Icons.all_inclusive_rounded,
                              color: currentCard.themeColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'KarmaRide',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      if (_currentPage < _cards.length - 1)
                        InkWell(
                          onTap: _completeOnboarding,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131826).withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF1E293B),
                                width: 1.0,
                              ),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      return _buildFullyTransparentStitchCard(_cards[index]);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_cards.length, (index) {
                    final bool isActive = index == _currentPage;
                    final targetCard = _cards[index];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: isActive ? 30 : 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isActive
                            ? targetCard.themeColor
                            : const Color(0xFF1E293B),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: targetCard.themeColor.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF131826).withValues(alpha: 0.85),
                        border: Border.all(
                          color: currentCard.themeColor.withValues(alpha: 0.55),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: currentCard.themeColor.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == _cards.length - 1
                                  ? 'Get Started'
                                  : 'Continue',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentPage == _cards.length - 1
                                  ? Icons.arrow_forward_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              size: _currentPage == _cards.length - 1 ? 20 : 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.apartment_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Trusted by 50+ IT Tech Parks & Corporate Campuses',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullyTransparentStitchCard(StitchBeamCardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Stack(
        children: [
          // â”€â”€â”€ 1. FULLY TRANSPARENT GOOGLE STITCH BORDER BEAM (0 Blur, 100% Clear) â”€â”€â”€
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _beamController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: FullyTransparentStitchBorderBeamPainter(
                      rotationProgress: _beamController.value,
                      pulseFactor: _pulseAnimation.value,
                      cardData: data,
                    ),
                  );
                },
              ),
            ),
          ),

          // â”€â”€â”€ 2. CARD CONTENT OVER TRANSPARENT BACKGROUND â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF090E1A).withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          RepaintBoundary(
                            child: RotationTransition(
                              turns: _dialController,
                              child: CustomPaint(
                                size: const Size(56, 56),
                                painter: SubtleDialPainter(
                                  color: data.themeColor,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF161E30).withValues(alpha: 0.70),
                              border: Border.all(
                                color: const Color(0xFF1E293B),
                                width: 1.0,
                              ),
                            ),
                            child: Icon(
                              data.icon,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161E30).withValues(alpha: 0.70),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF1E293B),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: data.themeColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: data.themeColor.withValues(alpha: 0.8),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              data.badgeText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    data.headline,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 12,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.description,
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 14.5,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                      shadows: [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 8,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: data.chips.map((chip) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161E30).withValues(alpha: 0.70),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF1E293B),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          chip,
                          style: const TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 Fully Transparent Google Stitch Border Beam Painter (Light Subtle Rim, Pure Luminous Inner Lightness)
/// 🎨 Exact Google Stitch Border Beam Painter (Volumetric Corner Aura + Crisp Neon Hairline)
class FullyTransparentStitchBorderBeamPainter extends CustomPainter {
  final double rotationProgress;
  final double pulseFactor;
  final StitchBeamCardData cardData;

  static const _sheenBlur = MaskFilter.blur(BlurStyle.normal, 18.0);
  static const _edgeBlur = MaskFilter.blur(BlurStyle.normal, 4.0);

  final Paint _baseRimPaint = Paint()
    ..color = const Color(0x8093C5FD) // Exact Tailwind #93c5fd80 (Ice-Blue Inset Ring)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  final Paint _innerSheenPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 48.0
    ..maskFilter = _sheenBlur
    ..blendMode = BlendMode.screen;

  final Paint _innerEdgePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8.0
    ..maskFilter = _edgeBlur
    ..blendMode = BlendMode.screen;

  final Paint _laserBeamPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6;

  FullyTransparentStitchBorderBeamPainter({
    required this.rotationProgress,
    required this.pulseFactor,
    required this.cardData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(28));

    // 1. Subtle perimeter rim
    canvas.drawRRect(rrect, _baseRimPaint);

    final double angle = rotationProgress * 2 * math.pi;

    // 2. High-Chroma Conic Sweep Gradient Shader
    final sweepShader = SweepGradient(
      center: Alignment.center,
      startAngle: 0.0,
      endAngle: math.pi * 2,
      transform: GradientRotation(angle),
      colors: cardData.beamColors,
      stops: cardData.beamStops,
    ).createShader(rect);

    // 3. ALL INNER VOLUMETRIC CORNER GLOW IS CLIPPED INSIDE THE CARD
    canvas.save();
    canvas.clipRRect(rrect);

    // A. Corner Volumetric Light Aura tracking the laser beam position
    final double alignX = math.cos(angle) * 0.88;
    final double alignY = math.sin(angle) * 0.88;
    final cornerAuraPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(alignX, alignY),
        radius: 0.75,
        colors: [
          cardData.innerGlowColor.withValues(alpha: 0.35 * pulseFactor),
          cardData.innerGlowColor.withValues(alpha: 0.12 * pulseFactor),
          const Color(0x00000000),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.screen;
    canvas.drawRRect(rrect, cornerAuraPaint);

    // B. Soft diffused inner edge sheen following the sweep colors
    _innerSheenPaint.shader = sweepShader;
    canvas.drawRRect(rrect, _innerSheenPaint);

    // C. Immediate inner edge lip
    _innerEdgePaint.shader = sweepShader;
    canvas.drawRRect(rrect, _innerEdgePaint);

    canvas.restore();

    // 4. Sharp Neon Laser Line on the border rim
    _laserBeamPaint.shader = sweepShader;
    canvas.drawRRect(rrect, _laserBeamPaint);
  }

  @override
  bool shouldRepaint(covariant FullyTransparentStitchBorderBeamPainter oldDelegate) =>
      oldDelegate.rotationProgress != rotationProgress ||
      oldDelegate.cardData != cardData;
}

class SubtleDialPainter extends CustomPainter {
  final Color color;

  SubtleDialPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final outerRing = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final tickPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius - 2, outerRing);

    const int totalTicks = 16;
    for (int i = 0; i < totalTicks; i++) {
      final double angle = (i * 2 * math.pi) / totalTicks;
      final double innerR = radius - 4.0;
      final double outerR = radius - 2.0;

      final p1 = Offset(center.dx + innerR * math.cos(angle),
          center.dy + innerR * math.sin(angle));
      final p2 = Offset(center.dx + outerR * math.cos(angle),
          center.dy + outerR * math.sin(angle));

      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SubtleDialPainter oldDelegate) => false;
}

class StitchBeamCardData {
  final String badgeText;
  final IconData icon;
  final String headline;
  final String description;
  final List<String> chips;
  final Color themeColor;
  final List<Color> beamColors;
  final List<double> beamStops;
  final Color innerGlowColor;

  const StitchBeamCardData({
    required this.badgeText,
    required this.icon,
    required this.headline,
    required this.description,
    required this.chips,
    required this.themeColor,
    required this.beamColors,
    required this.beamStops,
    required this.innerGlowColor,
  });
}
