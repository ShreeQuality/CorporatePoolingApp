import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class RideTrackingScreen extends StatefulWidget {
  final String rideId;
  const RideTrackingScreen({Key? key, required this.rideId}) : super(key: key);

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  double? _driverLat;
  double? _driverLng;
  int _routeIndex = 0;
  String _statusMessage = 'Subscribing to driver live GPS stream...';

  @override
  void initState() {
    super.initState();
    _startRealtimeTracking();
  }

  void _startRealtimeTracking() {
    _supabaseService.subscribeToDriverLocation(widget.rideId, (payload) {
      if (mounted) {
        setState(() {
          _driverLat = (payload['lat'] as num).toDouble();
          _driverLng = (payload['lng'] as num).toDouble();
          _routeIndex = payload['current_route_index'] ?? 0;
          _statusMessage = 'Driver moving on route index $_routeIndex';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Driver GPS Tracking 📍')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppTheme.cardDark,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.directions_car_sharp, size: 80, color: AppTheme.accentGreen),
                    const SizedBox(height: 16),
                    Text(_statusMessage, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    if (_driverLat != null) ...[
                      const SizedBox(height: 8),
                      Text('Coordinates: ${_driverLat?.toStringAsFixed(4)}, ${_driverLng?.toStringAsFixed(4)}', style: const TextStyle(color: AppTheme.textMuted)),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.backgroundDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.call),
                    label: const Text('Call Driver'),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentSaffron),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirm Drop'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Arrival Confirmed! Coins transferred to driver.')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
