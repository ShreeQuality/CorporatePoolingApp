import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

class ApiService {
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // ─── Auth APIs ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> registerCorporate(String fullName, String email, String password, String? phone) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/register-corporate'),
      headers: _headers,
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> registerPublic(String fullName, String email, String password, String? phone) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/register-public'),
      headers: _headers,
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/verify-otp'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true && data['data']['access_token'] != null) {
      setAuthToken(data['data']['access_token']);
    }
    return data;
  }

  // ─── Ride APIs ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> postRide(Map<String, dynamic> rideData) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/rides'),
      headers: _headers,
      body: jsonEncode(rideData),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> searchRides({
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
    String timeType = 'now',
    String? departTimestamp,
  }) async {
    final queryParams = {
      'pickup_lat': pickupLat.toString(),
      'pickup_lng': pickupLng.toString(),
      'drop_lat': dropLat.toString(),
      'drop_lng': dropLng.toString(),
      'time_type': timeType,
      if (departTimestamp != null) 'depart_timestamp': departTimestamp,
    };
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/rides/search').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    return jsonDecode(response.body);
  }

  // ─── Request APIs ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> requestRide(String rideId, Map<String, dynamic> requestData) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/rides/$rideId/request'),
      headers: _headers,
      body: jsonEncode(requestData),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> acceptRequest(String requestId) async {
    final response = await http.patch(
      Uri.parse('${AppConfig.apiBaseUrl}/requests/$requestId/accept'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> riderConfirmArrival(String requestId) async {
    final response = await http.patch(
      Uri.parse('${AppConfig.apiBaseUrl}/requests/$requestId/rider-confirm'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ─── Wallet APIs ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getWallet() async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/wallet'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }
}
