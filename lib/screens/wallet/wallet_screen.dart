import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ApiService _apiService = ApiService();
  int _balance = 150; // Demo starting balance
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  void _loadWalletData() async {
    try {
      final res = await _apiService.getWallet();
      if (res['success'] == true && res['data'] != null) {
        setState(() {
          _balance = res['data']['coin_balance'] ?? 150;
        });
      }
    } catch (e) {
      debugPrint('Wallet load error: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coin Wallet 🪙')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.accentSaffron, Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Spendable Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text('$_balance Coins', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Buy Coin Packages'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Recent Ledger Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  _buildTransactionTile(type: 'earn', title: 'Ride Earnings from Passenger', amount: '+15 Coins', date: 'Today, 8:30 AM'),
                  _buildTransactionTile(type: 'spend', title: 'Ride Payment to Driver', amount: '-10 Coins', date: 'Yesterday, 6:15 PM'),
                  _buildTransactionTile(type: 'credit', title: 'Corporate Bonus Credit', amount: '+50 Coins', date: 'Aug 8, 2026'),
                ],
              ),
            ),
    );
  }

  Widget _buildTransactionTile({
    required String type,
    required String title,
    required String amount,
    required String date,
  }) {
    final isPositive = type == 'earn' || type == 'credit';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isPositive ? AppTheme.accentGreen.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
            child: Icon(isPositive ? Icons.arrow_downward : Icons.arrow_upward, color: isPositive ? AppTheme.accentGreen : Colors.redAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(date, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isPositive ? AppTheme.accentGreen : Colors.redAccent)),
        ],
      ),
    );
  }
}
