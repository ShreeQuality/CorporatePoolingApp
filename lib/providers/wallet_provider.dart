import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/api_client.dart';

class WalletSummaryModel {
  final String userId;
  final String fullName;
  final double availableCoins;
  final double corporateGrantRemaining;
  final double lockedEscrow;
  final double lifetimeEarned;
  final double trustScore;
  final double co2SavedKg;

  const WalletSummaryModel({
    this.userId = '',
    this.fullName = 'Commuter',
    this.availableCoins = 0.0,
    this.corporateGrantRemaining = 0.0,
    this.lockedEscrow = 0.0,
    this.lifetimeEarned = 0.0,
    this.trustScore = 95.0,
    this.co2SavedKg = 0.0,
  });

  factory WalletSummaryModel.fromJson(Map<String, dynamic> json) {
    return WalletSummaryModel(
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Commuter',
      availableCoins: (json['available_coins'] as num?)?.toDouble() ?? 0.0,
      corporateGrantRemaining: (json['corporate_grant_remaining'] as num?)?.toDouble() ?? 0.0,
      lockedEscrow: (json['locked_escrow'] as num?)?.toDouble() ?? 0.0,
      lifetimeEarned: (json['lifetime_earned'] as num?)?.toDouble() ?? 0.0,
      trustScore: (json['trust_score'] as num?)?.toDouble() ?? 95.0,
      co2SavedKg: (json['co2_saved_kg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WalletProvider extends ChangeNotifier {
  WalletSummaryModel _summary = const WalletSummaryModel();
  bool _isLoading = false;
  String? _errorMessage;

  WalletSummaryModel get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSummary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.get('/wallet/summary');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] != null) {
          _summary = WalletSummaryModel.fromJson(body['data']);
        }
      } else {
        _errorMessage = 'Failed to load wallet summary (${res.statusCode})';
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[WalletProvider] fetchSummary error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
