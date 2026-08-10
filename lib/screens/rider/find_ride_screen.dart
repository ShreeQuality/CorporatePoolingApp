import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ride_model.dart';

class FindRideScreen extends StatefulWidget {
  const FindRideScreen({Key? key}) : super(key: key);

  @override
  State<FindRideScreen> createState() => _FindRideScreenState();
}

class _FindRideScreenState extends State<FindRideScreen> {
  final ApiService _apiService = ApiService();
  List<RideModel> _matchedRides = [];
  bool _isSearching = false;

  void _performSearch() async {
    setState(() => _isSearching = true);

    try {
      final res = await _apiService.searchRides(
        pickupLat: 19.0760,
        pickupLng: 72.8777,
        dropLat: 19.2183,
        dropLng: 72.9781,
      );

      if (res['success'] == true && res['data']['rides'] != null) {
        final List raw = res['data']['rides'];
        setState(() {
          _matchedRides = raw.map((r) => RideModel.fromJson(r)).toList();
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }

    if (mounted) setState(() => _isSearching = false);
  }

  void _requestJoinRide(RideModel ride) async {
    final payload = {
      'pickup_address': 'Bandra West, Mumbai',
      'pickup_lat': 19.0596,
      'pickup_lng': 72.8295,
      'drop_address': 'Thane West, Mumbai',
      'drop_lat': 19.2183,
      'drop_lng': 72.9781,
    };

    try {
      final res = await _apiService.requestRide(ride.id, payload);
      if (res['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request sent to driver! ${ride.coinPerSeat} coins locked.')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to send request')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Matching Rides (100% Engine)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Run 2-Phase Matching Engine'),
              onPressed: _isSearching ? null : _performSearch,
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _matchedRides.isEmpty
                    ? const Center(child: Text('Tap button above to search rides along your route.', style: TextStyle(color: AppTheme.textMuted)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _matchedRides.length,
                        itemBuilder: (ctx, idx) => _buildRideMatchCard(_matchedRides[idx]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideMatchCard(RideModel ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGreen.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.accentGreen, borderRadius: BorderRadius.circular(12)),
                child: Text('${ride.matchScore?.round() ?? 95}% Match', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: AppTheme.accentSaffron, size: 20),
                  const SizedBox(width: 4),
                  Text('${ride.coinPerSeat} Coins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('From: ${ride.fromAddress}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('To: ${ride.toAddress}', style: const TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${ride.availableSeats} Seats Left', style: const TextStyle(color: AppTheme.textMuted)),
              ElevatedButton(
                onPressed: () => _requestJoinRide(ride),
                child: const Text('Request Join'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
