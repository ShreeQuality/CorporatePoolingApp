import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../core/api_client.dart';
import '../core/secure_storage_service.dart';
import '../core/biometric_service.dart';
import '../models/user_model.dart';

enum AppRole { rider, driver }
enum CommuteMode { rider, driver }

/// Auth Provider — Section 4 Implementation
/// Coordinates Steps 1 to 5:
///   Step 1: Phone / Work Email OTP verification
///   Step 2: 90-Day JWT Session Persistence
///   Step 3: Role Detection & Access Routing
///   Step 4: Hardware Biometric Lock
///   Step 5: FCM Device Token Registration
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  AppRole _activeRole = AppRole.rider;
  bool _isLoading = false;
  bool _isBiometricLocked = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  AppRole get activeRole => _activeRole;
  CommuteMode get activeMode => _activeRole == AppRole.rider ? CommuteMode.rider : CommuteMode.driver;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isBiometricLocked => _isBiometricLocked;
  String? get errorMessage => _errorMessage;

  void toggleRole(AppRole role) {
    _activeRole = role;
    notifyListeners();
  }

  void toggleCommuteMode(CommuteMode mode) {
    _activeRole = mode == CommuteMode.rider ? AppRole.rider : AppRole.driver;
    notifyListeners();
  }

  // ─── STEP 2: SESSION INITIALIZATION ON APP START ─────────────

  Future<bool> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final jwt = await SecureStorageService.getJwt();
      if (jwt == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if biometric lock is required
      final biometricEnabled = await SecureStorageService.isBiometricEnabled();
      if (biometricEnabled) {
        _isBiometricLocked = true;
      }

      // Fetch fresh profile from backend
      final res = await ApiClient.get('/auth/me');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] != null) {
          _currentUser = UserModel.fromJson(body['data']);
          _isLoading = false;
          notifyListeners();

          // Sync FCM token in background
          _syncFcmToken();
          return true;
        }
      }
    } catch (e) {
      debugPrint('[AuthProvider] Auto-login error: $e');
    }

    // If session is expired or invalid, clear storage
    await SecureStorageService.clearAll();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── STEP 1: AUTHENTICATION (LOGIN & OTP) ───────────────────

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.post('/auth/login', {
        'email': email.trim(),
        'password': password,
      });

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final data = body['data'];
        final jwt = data['access_token'];
        final refresh = data['refresh_token'];
        final userJson = data['user'];

        _currentUser = UserModel.fromJson(userJson);

        // Step 2: Persist 90-day session
        await SecureStorageService.saveUserSession(
          userId: _currentUser!.id,
          role: _currentUser!.role,
          jwt: jwt,
          refreshToken: refresh,
        );

        _isLoading = false;
        notifyListeners();

        // Step 5: Save device FCM push token
        _syncFcmToken();
        return true;
      } else {
        _errorMessage = body['message'] ?? 'Login failed. Please check credentials.';
      }
    } catch (e) {
      _errorMessage = 'Network error: Unable to reach server. Please check your connection.';
      debugPrint('[AuthProvider] Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.post('/auth/verify-otp', {
        'email': email.trim(),
        'otp': otp.trim(),
      });

      final body = jsonDecode(res.body);
      _isLoading = false;
      notifyListeners();
      return body;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> registerCorporate({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final res = await ApiClient.post('/auth/register-corporate', {
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
      });
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> registerPublic({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final res = await ApiClient.post('/auth/register-public', {
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
      });
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── STEP 4: BIOMETRIC UNLOCK ────────────────────────────────

  Future<bool> unlockWithBiometrics() async {
    final success = await BiometricService.authenticate(
      reason: 'Scan fingerprint or Face ID to unlock Corporate Pooling',
    );

    if (success) {
      _isBiometricLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> enableBiometricLock(bool enable) async {
    await SecureStorageService.setBiometricEnabled(enable);
    notifyListeners();
  }

  // ─── STEP 5: FCM DEVICE TOKEN REGISTRATION ───────────────────

  Future<void> _syncFcmToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();

      if (token != null) {
        await ApiClient.post('/notifications/fcm-token', {
          'fcm_token': token,
          'platform': 'android',
        });
        debugPrint('[AuthProvider] Device FCM token synced to backend successfully.');
      }
    } catch (e) {
      debugPrint('[AuthProvider] FCM token sync error (non-fatal): $e');
    }
  }

  // ─── LOGOUT ──────────────────────────────────────────────────

  Future<void> logout() async {
    await SecureStorageService.clearAll();
    _currentUser = null;
    _isBiometricLocked = false;
    notifyListeners();
  }
}
