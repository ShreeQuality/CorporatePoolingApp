import 'package:corporate_pooling_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_screen.dart';
import '../../widgets/star_rain_1.dart';

// Active chakra: V11-V2 (Gyroscopic Precession)
// Other versions (v1, v3Ã¢â‚¬â€œv10, newsudarshan) kept as files in /widgets but NOT imported
// to avoid loading 70+ animation controllers into memory on app start.
import '../../widgets/sudarshan_chakra_11_v2.dart';

/// Screen 1: KarmaRide Sacred Splash Screen (Dedicated Night Mode Edition - V11 Vibration Studies 1 to 10 + V11-V10-NEW)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Locked to V11-V2. Other versions kept as files in /widgets but not imported.
  // This prevents 70 idle AnimationControllers from running in the background.
  static const int _selectedVariationIndex = 0;

  // Only V11-V2 entry kept. Add more here when you re-import other versions.
  static const List<Map<String, String>> _vibrationPatterns = [
    {
      'label': 'V11-V2',
      'name': 'Gyroscopic Precession',
      'desc': 'Dynamic 3D conical multi-axis wobble & 12Hz stabilizer hum',
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  void _handleNextPressed() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildChakraWidget() {
    // V11-V2: Gyroscopic Precession
    return const SudarshanChakra11V2(key: ValueKey('v11v2'), size: 165);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final chakraCenter = Offset(screenSize.width / 2, screenSize.height * 0.46);
    final chakraExclusion = Rect.fromCenter(
      center: chakraCenter,
      width: 220,
      height: 220,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF02050F),
      body: Stack(
          children: [
            // PRE-WARM: Compiles GPU Shaders for Onboarding silently while Chakra spins
            const Offstage(offstage: true, child: OnboardingScreen()),

          // 1. Base Radial Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.15),
                  radius: 1.15,
                  colors: [
                    Color(0xFF080E24),
                    Color(0xFF040815),
                    Color(0xFF02050F),
                    Color(0xFF010308),
                  ],
                  stops: [0.0, 0.35, 0.70, 1.0],
                ),
              ),
            ),
          ),

          // 2. StarRain1: Linear Vertical Stardust Drift (Excludes Chakra Center)
          Positioned.fill(
            child: StarRain1(
              exclusionZone: chakraExclusion,
            ),
          ),

          // 3. Main Centered Splash Screen Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // UPPER V11 VIBRATION PATTERN SELECTOR BAR (V11-V1 to V11-V10)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_vibrationPatterns.length, (idx) {
                        final isSel = idx == _selectedVariationIndex;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: InkWell(
                            onTap: () {
                              // Selector is locked to V11-V2 during this sprint.
                              // To add more versions: re-import the file & add to _vibrationPatterns.
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9.5,
                                vertical: 6.5,
                              ),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? const Color(0xFFFF8F00)
                                    : AppTheme.glassWhite08,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSel
                                      ? const Color(0xFFFFB74D)
                                      : AppTheme.glassWhite15,
                                  width: isSel ? 1.5 : 1.0,
                                ),
                                boxShadow: isSel
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFFF8F00).withValues(alpha: 0.45),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                _vibrationPatterns[idx]['label']!,
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                  color: isSel ? Colors.white : const Color(0xFFB0BEC5),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // PATTERN NAME & DESCRIPTION SUB-BADGE
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.glassWhite10,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_vibrationPatterns[_selectedVariationIndex]['label']} • ${_vibrationPatterns[_selectedVariationIndex]['name']}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFFB74D),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _vibrationPatterns[_selectedVariationIndex]['desc']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF90A4AE),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // V11 CHAKRA (LIVE SELECTED VARIATION)
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: RepaintBoundary(
                        child: _buildChakraWidget(),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // BRAND LOGO TEXT
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'KarmaRide',
                    style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFFF8F0),
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFFF8F00).withValues(alpha: 0.50),
                          blurRadius: 22,
                        ),
                        Shadow(
                          color: const Color(0xFFFF5A00).withValues(alpha: 0.30),
                          blurRadius: 36,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // SUBTITLE
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Smart • Verified • Sustainable Commutes',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFB74D),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // INTERACTIVE NEXT BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF8F00),
                          Color(0xFFE65100),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8F00).withValues(alpha: 0.45),
                          blurRadius: 22,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleNextPressed,
                        borderRadius: BorderRadius.circular(27),
                        splashColor: Colors.white.withValues(alpha: 0.25),
                        highlightColor: AppTheme.glassWhite15,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: GoogleFonts.inter(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // SECURITY BADGE
                Text(
                  'Secured with Enterprise SSO & Biometrics',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF78909C),
                    letterSpacing: 0.25,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

