import '../../core/secure_storage_service.dart';
import 'dart:async';
import '../../widgets/core/app_background.dart';
import 'package:corporate_pooling_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/sudarshan_chakra_11_v2.dart';

/// Screen 1: KarmaRide Sacred Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isChakraArrived = false;
  Timer? _navigationTimer;

  static const int _selectedVariationIndex = 0;
  static const List<Map<String, String>> _vibrationPatterns = [
    {
      'label': 'V11-V2',
      'name': 'Gyroscopic Precession',
      'desc': 'Dynamic 3D conical multi-axis wobble & 12Hz stabilizer hum',
    },
  ];

  @override
  void dispose() {
    _navigationTimer?.cancel();
    AppBackground.exclusionZone.value = null;
    super.dispose();
  }

  void _handleChakraArrived() async {
    if (!mounted) return;
    setState(() {
      _isChakraArrived = true;
    });

    // Step 1: Check local secure storage for an active session token
    final jwtToken = await SecureStorageService.getJwt();

    // Wait 3 seconds after chakra arrival, then navigate automatically
    _navigationTimer?.cancel();
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (jwtToken != null && jwtToken.isNotEmpty) {
        // Already registered/logged in -> Go directly to Home Dashboard
        context.go('/home');
      } else {
        // New user -> Go to Onboarding
        context.go('/onboarding');
      }
    });
  }

  Widget _buildChakraWidget() {
    return SudarshanChakraEntrance(
      key: const ValueKey('v11v2'),
      size: 165,
      onArrival: _handleChakraArrived,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final chakraCenter = Offset(screenSize.width / 2, screenSize.height * 0.44);
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
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // UPPER V11 VIBRATION PATTERN SELECTOR BAR
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
                            onTap: () {},
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
                                style: TextStyle(
                                  fontFamily: 'Inter',
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
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFB74D),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _vibrationPatterns[_selectedVariationIndex]['desc']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Color(0xFF90A4AE),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // V11 CHAKRA (LIVE SELECTED VARIATION)
                Center(
                  child: RepaintBoundary(
                    child: _buildChakraWidget(),
                  ),
                ),

                // Positioned slightly higher, neatly right under the chakra
                const SizedBox(height: 16),

                // BRAND LOGO TEXT & SUBTITLE (Fades in once chakra arrives)
                AnimatedOpacity(
                  opacity: _isChakraArrived ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  child: Column(
                    children: [
                      Text(
                        'KarmaRide',
                        style: TextStyle(
                          fontFamily: 'Inter',
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
                      const SizedBox(height: 6),
                      const Text(
                        'Smart • Verified • Sustainable Commutes',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFB74D),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 4),

                // SECURITY BADGE
                const Text(
                  'Secured with Enterprise SSO & Biometrics',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF78909C),
                    letterSpacing: 0.25,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
