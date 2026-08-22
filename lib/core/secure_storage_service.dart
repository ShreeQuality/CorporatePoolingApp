import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage Service
/// Manages 90-day persistent JWT tokens, refresh tokens, and user credentials
/// using Android Keystore and iOS Keychain.
/// Source of Truth: Section 4 — Step 2 (JWT Token Management)
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _keyJwtToken = 'jwt_access_token';
  static const String _keyRefreshToken = 'jwt_refresh_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserRole = 'auth_user_role';
  static const String _keyBiometricEnabled = 'biometric_lock_enabled';
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';

  // ─── JWT Access Token ─────────────────────────────────────────

  static Future<void> saveJwt(String token) async {
    await _storage.write(key: _keyJwtToken, value: token);
  }

  static Future<String?> getJwt() async {
    return await _storage.read(key: _keyJwtToken);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  // ─── User Profile Cache ───────────────────────────────────────

  static Future<void> saveUserSession({
    required String userId,
    required String role,
    required String jwt,
    String? refreshToken,
  }) async {
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyUserRole, value: role);
    await _storage.write(key: _keyJwtToken, value: jwt);
    if (refreshToken != null) {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    }
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  static Future<String?> getUserRole() async {
    return await _storage.read(key: _keyUserRole);
  }

  // ─── Biometric Settings ───────────────────────────────────────

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometricEnabled, value: enabled.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _keyBiometricEnabled);
    return val == 'true';
  }

  // ─── Onboarding Settings ─────────────────────────────────────
  
  static Future<void> setOnboardingSeen(bool seen) async {
    await _storage.write(key: _keyHasSeenOnboarding, value: seen.toString());
  }

  static Future<bool> hasSeenOnboarding() async {
    final val = await _storage.read(key: _keyHasSeenOnboarding);
    return val == 'true';
  }

  // ─── Clear / Logout ───────────────────────────────────────────

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
