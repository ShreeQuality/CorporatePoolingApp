import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// Biometric Authentication Service
/// Hardware Face ID / Fingerprint sensor interface.
/// Source of Truth: Section 4 — Step 4 (Biometric Lock)
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if the physical device hardware supports biometrics and is enrolled.
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      print('[BiometricService] Check error: ${e.message}');
      return false;
    }
  }

  /// Lists available biometric hardware types (e.g. fingerprint, face, weak, strong).
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('[BiometricService] List error: ${e.message}');
      return [];
    }
  }

  /// Prompts the user with native Face ID / Fingerprint modal.
  static Future<bool> authenticate({
    String reason = 'Please authenticate to access Corporate Pooling',
  }) async {
    try {
      final bool available = await isBiometricAvailable();
      if (!available) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        print('[BiometricService] No biometrics enrolled on device.');
      } else if (e.code == auth_error.lockedOut || e.code == auth_error.permanentlyLockedOut) {
        print('[BiometricService] Biometrics temporarily locked out.');
      } else {
        print('[BiometricService] Auth error: ${e.message}');
      }
      return false;
    }
  }
}
