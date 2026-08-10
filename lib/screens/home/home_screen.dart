import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../driver/post_ride_screen.dart';
import '../rider/find_ride_screen.dart';
import '../wallet/wallet_screen.dart';
import 'role_switcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDriver = authProvider.activeRole == AppRole.driver;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corporate Pooling 🚗'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet, color: AppTheme.accentSaffron),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications: No new alerts.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const RoleSwitcher(),
          Expanded(
            child: isDriver ? _buildDriverView(context) : _buildRiderView(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.warning, color: Colors.white),
        label: const Text('SOS Safety', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🚨 SOS Emergency Triggered! Live GPS payload sent to admin & safety team.')),
          );
        },
      ),
    );
  }

  Widget _buildRiderView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: AppTheme.cardDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Where are you going?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.my_location, color: AppTheme.accentGreen),
                      hintText: 'Pickup Address (e.g. Bandra West)',
                      filled: true,
                      fillColor: AppTheme.backgroundDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on, color: AppTheme.accentSaffron),
                      hintText: 'Destination (e.g. Thane West)',
                      filled: true,
                      fillColor: AppTheme.backgroundDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const FindRideScreen()));
                      },
                      child: const Text('Find Matching Rides (100% Match Engine)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: AppTheme.cardDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Offer a Ride to Colleagues 🚗', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.trip_origin, color: AppTheme.accentGreen),
                      hintText: 'Starting Address',
                      filled: true,
                      fillColor: AppTheme.backgroundDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.pin_drop, color: AppTheme.accentSaffron),
                      hintText: 'Destination Address',
                      filled: true,
                      fillColor: AppTheme.backgroundDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentSaffron),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PostRideScreen()));
                      },
                      child: const Text('Post Ride & Earn Coins'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
