import 'package:go_router/go_router.dart';

import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/onboarding_screen.dart';
import '../../screens/auth/phone_login_screen.dart';
import '../../screens/auth/role_selection_screen.dart';
import '../../screens/auth/corporate_verify_screen.dart';
import '../../screens/auth/aadhaar_kyc_screen.dart';
import '../../screens/auth/driver_kyc_screen.dart';
import '../../screens/home/home_shell_screen.dart';
import '../../core/services/aadhaar_kyc_validator.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/phone-login',
      builder: (context, state) => const PhoneLoginScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/corporate-verify',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CorporateVerifyScreen(
          preselectedRole: extra?['preselectedRole'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/aadhaar-kyc',
      builder: (context, state) {
        final payload = state.extra as Map<String, dynamic>?;
        return AadhaarKycScreen(previousPayload: payload);
      },
    ),
    GoRoute(
      path: '/driver-kyc',
      builder: (context, state) {
        final profile = state.extra as AadhaarProfilePayload?;
        return DriverKycScreen(verifiedAadhaarProfile: profile);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        return HomeShellScreen(arguments: args);
      },
    ),
  ],
);
