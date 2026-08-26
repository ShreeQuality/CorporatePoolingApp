import 'package:corporate_pooling_app/core/theme/app_theme.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/secure_storage_service.dart';

/// Screen 2: Clean Crystal Onboarding Experience (Zero Fog / Pure Transparency)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _beamController;
  late final AnimationController _dialController;

  static const List<StitchBeamCardData> _cards = [
    StitchBeamCardData(
      badgeText: 'CORPORATE VERIFIED',
      icon: Icons.shield_outlined,
      headline: 'Rides only with\nverified colleagues',
      description:
          'Single Sign-On (SSO) with your corporate email and government ID verification ensures total safety.',
      chips: ['@company.com only', 'Zero strangers', '100% trust'],
      themeColor: Color(0xFF00E5FF),
      beamColors: [
        Color(0x0000E5FF),
        Color(0xFF00E5FF),
        Color(0xFF0088FF),
        Color(0x000088FF),
      ],
      beamStops: [0.0, 0.35, 0.65, 1.0],
      innerGlowColor: Color(0xFF00E5FF),
    ),
    StitchBeamCardData(
      badgeText: 'ZERO COMMISSION',
      icon: Icons.percent_rounded,
      headline: '0% commission.\nKeep every rupee.',
      description:
          'KarmaCoins pass directly from rider to driver. No platform cuts, no hidden fees, no surge taxes.',
      chips: ['No platform cut', 'Direct Karma Coins', 'Instant payouts'],
      themeColor: Color(0xFFFFB300),
      beamColors: [
        Color(0x00FFB300),
        Color(0xFFFFB300),
        Color(0xFFFF6D00),
        Color(0x00FF6D00),
      ],
      beamStops: [0.0, 0.35, 0.65, 1.0],
      innerGlowColor: Color(0xFFFFB300),
    ),
    StitchBeamCardData(
      badgeText: 'CARBON POSITIVE',
      icon: Icons.eco_outlined,
      headline: 'Track your carbon\nsavings every km',
      description:
          'Earn green rewards, climb corporate sustainability leaderboards, and turn every commute into an eco win.',
      chips: ['Real-time CO2', 'Eco badges', 'Green credits'],
      themeColor: Color(0xFF00E676),
      beamColors: [
        Color(0x0000E676),
        Color(0xFF00E676),
        Color(0xFF059669),
        Color(0x0000E676),
      ],
      beamStops: [0.0, 0.35, 0.65, 1.0],
      innerGlowColor: Color(0xFF00E676),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _beamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _dialController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _beamController.repeat();
        _dialController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _beamController.dispose();
    _dialController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    SecureStorageService.setOnboardingSeen(true);

    if (!mounted) return;
    context.go('/phone-login');
  }

  void _nextPage() {
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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF161E30),
                          border: Border.all(
                            color: const Color(0xFF1E293B),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.local_taxi_rounded,
                          color: Color(0xFF00E5FF),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'KarmaRide',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _cards.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final data = _cards[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: _buildCleanCrystalCard(data),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_cards.length, (index) {
                  final isSelected = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? currentCard.themeColor
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                          Icons.arrow_forward_rounded,
                          color: currentCard.themeColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanCrystalCard(StitchBeamCardData data) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _beamController,
            builder: (context, child) {
              return CustomPaint(
                painter: CleanCrystalBorderBeamPainter(
                  rotationProgress: _beamController.value,
                  cardData: data,
                ),
              );
            },
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.transparent,
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
                            style: TextStyle(
                              color: data.themeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
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
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.description,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    height: 1.5,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: data.chips.map((chip) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
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
    );
  }
}

/// Clean Crystal Border Beam Painter (Zero Fog / No Blurs)
class CleanCrystalBorderBeamPainter extends CustomPainter {
  final double rotationProgress;
  final StitchBeamCardData cardData;

  final Paint _baseRimPaint = Paint()
    ..color = const Color(0x40FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  final Paint _laserGlowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.5;

  final Paint _laserBeamPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6;

  CleanCrystalBorderBeamPainter({
    required this.rotationProgress,
    required this.cardData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(28));

    canvas.drawRRect(rrect, _baseRimPaint);

    final double angle = rotationProgress * 2 * math.pi;

    final sweepShader = SweepGradient(
      center: Alignment.center,
      startAngle: 0.0,
      endAngle: math.pi * 2,
      transform: GradientRotation(angle),
      colors: cardData.beamColors,
      stops: cardData.beamStops,
    ).createShader(rect);

    _laserGlowPaint.shader = sweepShader;
    canvas.drawRRect(rrect, _laserGlowPaint);

    _laserBeamPaint.shader = sweepShader;
    canvas.drawRRect(rrect, _laserBeamPaint);
  }

  @override
  bool shouldRepaint(covariant CleanCrystalBorderBeamPainter oldDelegate) =>
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

    final tickPaint = Paint()
      ..color = color.withValues(alpha: 0.40)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

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
