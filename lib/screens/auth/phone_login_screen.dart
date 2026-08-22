import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/star_rain_1.dart';

/// Screen 3 (Step 1): Phone Login Screen
/// Features continuous Stardust Rainfall animation, glowing Frosted Glassmorphism Card,
/// and smooth interactive input controls.
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  
  bool _isFocused = false;
  String _countryCode = '+91';

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _phoneFocusNode.addListener(() {
      setState(() {
        _isFocused = _phoneFocusNode.hasFocus;
      });
    });

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Layer 1: Live Stardust Rainfall Animation (Matching Screen 1 & 2)
          const Positioned.fill(
            child: StarRain1(),
          ),

          // 2. Layer 2: Subtle Ambient Light Glows
          Positioned(
            top: size.height * 0.12,
            left: size.width * 0.1,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withOpacity(0.08),
                    const Color(0xFF6C63FF).withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Layer 3: Main Scrollable Content Area
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Emblem & Title
                    _buildBrandHeader(),

                    const SizedBox(height: 28),

                    // Floating Frosted Glass Card
                    _buildGlassCard(context),

                    const SizedBox(height: 24),

                    // Trust / Encryption Badge
                    _buildSecurityFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Brand Emblem & Title Header
  Widget _buildBrandHeader() {
    return Column(
      children: [
        // Glowing Icon Badge
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00E5FF).withOpacity(0.18),
                    const Color(0xFF6C63FF).withOpacity(0.12),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withOpacity(_glowAnimation.value),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.25 * _glowAnimation.value),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                color: Color(0xFF00E5FF),
                size: 36,
              ),
            );
          },
        ),

        const SizedBox(height: 14),

        // Brand Name
        const Text(
          'KarmaRide',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 4),

        // Tagline
        Text(
          'Corporate Commute Network',
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 13,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  /// Frosted Glassmorphism Card
  Widget _buildGlassCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1630).withOpacity(0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isFocused
                  ? const Color(0xFF00E5FF).withOpacity(0.55)
                  : Colors.white.withOpacity(0.12),
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? const Color(0xFF00E5FF).withOpacity(0.15)
                    : Colors.black.withOpacity(0.35),
                blurRadius: _isFocused ? 28 : 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Heading
              const Text(
                'Welcome Back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Enter your registered mobile number to receive a 6-digit verification code.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.60),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 22),

              // Phone Input Field with Country Code Pill
              _buildPhoneInputField(),

              const SizedBox(height: 20),

              // Primary Action Button ("Get Verification Code")
              _buildGetOtpButton(),

              const SizedBox(height: 20),

              // Divider "OR"
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.white.withOpacity(0.12),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.40),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.white.withOpacity(0.12),
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Secondary Button (Corporate Email Sign-In)
              _buildCorporateEmailButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Phone Number Input Field
  Widget _buildPhoneInputField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF060B1B).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused
              ? const Color(0xFF00E5FF).withOpacity(0.60)
              : Colors.white.withOpacity(0.10),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Country Code Dropdown Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              border: Border(
                right: BorderSide(
                  color: Colors.white.withOpacity(0.10),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇮🇳', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  _countryCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white.withOpacity(0.50),
                  size: 16,
                ),
              ],
            ),
          ),

          // Numeric Phone Input
          Expanded(
            child: TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
              cursorColor: const Color(0xFF00E5FF),
              decoration: InputDecoration(
                hintText: '98765 43210',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.0,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Primary Glowing Button ("Get Verification Code")
  Widget _buildGetOtpButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00E5FF),
            Color(0xFF0088FF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Step 1 UI feedback (Haptic feedback)
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Phone entered: ${_countryCode} ${_phoneController.text.isEmpty ? "(empty)" : _phoneController.text}',
                ),
                backgroundColor: const Color(0xFF0E1630),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get Verification Code',
                  style: TextStyle(
                    color: Color(0xFF030712),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF030712),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Secondary Button (Corporate Email)
  Widget _buildCorporateEmailButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            HapticFeedback.lightImpact();
          },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.badge_outlined,
                  color: Colors.white.withOpacity(0.75),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Continue with Corporate Email',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Security & Encryption Footer
  Widget _buildSecurityFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          color: Colors.white.withOpacity(0.40),
          size: 13,
        ),
        const SizedBox(width: 6),
        Text(
          '256-Bit Encrypted • Verified Corporate Commute',
          style: TextStyle(
            color: Colors.white.withOpacity(0.40),
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
