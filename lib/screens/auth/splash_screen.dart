import '../../core/secure_storage_service.dart';
import '../../widgets/core/app_background.dart';
import 'package:corporate_pooling_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/star_rain_1.dart';

import '../../widgets/sudarshan_chakra_11_v1.dart';
import '../../widgets/sudarshan_chakra_11_v2.dart';
import '../../widgets/sudarshan_chakra_11_v3.dart';
import '../../widgets/sudarshan_chakra_11_v4.dart';
import '../../widgets/sudarshan_chakra_11_v5.dart';
import '../../widgets/sudarshan_chakra_11_v6.dart';
import '../../widgets/sudarshan_chakra_11_v7.dart';
import '../../widgets/sudarshan_chakra_11_v8.dart';
import '../../widgets/sudarshan_chakra_11_v9.dart';
import '../../widgets/sudarshan_chakra_11_v10.dart';
import '../../widgets/newsudarshan_chakra.dart';

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

  // Active variation index (0: V11-V1 ... 9: V11-V10, 10: V11-V10-NEW). Default is 1 (V11-V2).
  int _selectedVariationIndex = 1;

  final List<Map<String, String>> _vibrationPatterns = [
    {
      'label': 'V11-V1',
      'name': 'Heartbeat (Lub-Dub)',
      'desc': 'Rhythmic dual biological pulse with serene rest phase',
    },
    {
      'label': 'V11-V2',
      'name': 'Gyroscopic Precession',
      'desc': 'Dynamic 3D conical multi-axis wobble & 12Hz stabilizer hum',
    },
    {
      'label': 'V11-V3',
      'name': 'Harmonic Hum',
      'desc': 'Continuous high-frequency acoustic resonance (20Hz) & breathing',
    },
    {
      'label': 'V11-V4',
      'name': 'Charge & Snap',
      'desc': 'Tense inward energy compression -> Explosive whip-crack snap release',
    },
    {
      'label': 'V11-V5',
      'name': 'Staccato Tick',
      'desc': 'Precision chronometer escapement / 4 crisp mechanical ratchet ticks/sec',
    },
    {
      'label': 'V11-V6',
      'name': 'Multi-Layer Polyphonic',
      'desc': 'Independent layer physics: 1.2Hz perimeter heave, 16Hz shimmer, 24Hz plasma',
    },
    {
      'label': 'V11-V7',
      'name': 'Fast Core + Slow Ring',
      'desc': 'Deep 3D parallax feel: Slow 14s rim + Fast core',
    },
    {
      'label': 'V11-V8',
      'name': 'Turbo Inner Chakra',
      'desc': 'Fast inner wheel (3.5s) & stars (2.2s/1.0s) + Slow outer rim (14s)',
    },
    {
      'label': 'V11-V9',
      'name': 'Slow Swell & Exhale',
      'desc': 'Gentle slow energy charge (2.5s) -> Smooth organic sinusoidal release (No snap)',
    },
    {
      'label': 'V11-V10',
      'name': 'Harmonic Micro-Precession',
      'desc': 'Smooth V9 energy swell + Delicate micro 3D gyro tilt (+-1.2° pitch/yaw/roll)',
    },
    {
      'label': 'V11-V10-NEW',
      'name': 'New Sudarshan Chakra',
      'desc': 'White Theme & Pure Kinetic Vibration Tremor with Inverted 3D Perspective Tilt',
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

  void _handleNextPressed() async {
    final jwtToken = await SecureStorageService.getJwt();
    if (!mounted) return;
    if (jwtToken != null && jwtToken.isNotEmpty) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    AppBackground.exclusionZone.value = null;
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildChakraWidget() {
    switch (_selectedVariationIndex) {
      case 0:
        return const SudarshanChakra11V1(key: ValueKey('v11v1'), size: 165);
      case 1:
        // V11-V2: Gyroscopic Precession with "arriving from far away" entrance
        return const SudarshanChakraEntrance(key: ValueKey('v11v2'), size: 165);
      case 2:
        return const SudarshanChakra11V3(key: ValueKey('v11v3'), size: 165);
      case 3:
        return const SudarshanChakra11V4(key: ValueKey('v11v4'), size: 165);
      case 4:
        return const SudarshanChakra11V5(key: ValueKey('v11v5'), size: 165);
      case 5:
        return const SudarshanChakra11V6(key: ValueKey('v11v6'), size: 165);
      case 6:
        return const SudarshanChakra11V7(key: ValueKey('v11v7'), size: 165);
      case 7:
        return const SudarshanChakra11V8(key: ValueKey('v11v8'), size: 165);
      case 8:
        return const SudarshanChakra11V9(key: ValueKey('v11v9'), size: 165);
      case 9:
        return const SudarshanChakra11V10(key: ValueKey('v11v10'), size: 165);
      case 10:
        return const NewSudarshanChakra(key: ValueKey('v11v10_new'), size: 165);
      default:
        return const NewSudarshanChakra(key: ValueKey('v11v10_def'), size: 165);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final chakraCenter = Offset(screenSize.width / 2, screenSize.height * 0.46);
    final chakraExclusion = Rect.fromCenter(
      center: chakraCenter,
      width: 240,
      height: 240,
    );

    // Keep global StarRain exclusion zone synchronized with chakra position
    if (AppBackground.exclusionZone.value != chakraExclusion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AppBackground.exclusionZone.value = chakraExclusion;
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
          children: [
          // Main Centered Splash Screen Content
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
                              setState(() {
                                _selectedVariationIndex = idx;
                              });
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
                                style: TextStyle(fontFamily: 'Inter', 
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
                          '${_vibrationPatterns[_selectedVariationIndex]['label']} \u2022 ${_vibrationPatterns[_selectedVariationIndex]['name']}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Inter', 
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
                          style: TextStyle(fontFamily: 'Inter', 
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
                    style: TextStyle(fontFamily: 'Inter', 
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
                    'Smart \u2022 Verified \u2022 Sustainable Commutes',
                    style: TextStyle(fontFamily: 'Inter', 
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
                                style: TextStyle(fontFamily: 'Inter', 
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
                  style: TextStyle(fontFamily: 'Inter', 
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


