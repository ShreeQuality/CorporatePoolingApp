import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/user_model.dart';

enum AppRole { rider, driver }

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  UserModel? _currentUser;
  AppRole _activeRole = AppRole.rider;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  AppRole get activeRole => _activeRole;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  void toggleRole(AppRole role) {
    _activeRole = role;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.login(email, password);
      if (res['success'] == true && res['data']['user'] != null) {
        _currentUser = UserModel.fromJson(res['data']['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<Map<String, dynamic>> registerCorporate({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      return await _apiService.registerCorporate(fullName, email, password, phone);
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
      return await _apiService.registerPublic(fullName, email, password, phone);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      return await _apiService.verifyOtp(email, otp);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
