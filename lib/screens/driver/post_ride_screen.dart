import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class PostRideScreen extends StatefulWidget {
  const PostRideScreen({Key? key}) : super(key: key);

  @override
  State<PostRideScreen> createState() => _PostRideScreenState();
}

class _PostRideScreenState extends State<PostRideScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  int _seats = 3;
  int _coinPrice = 10;
  String _timeType = 'now';
  final List<String> _selectedDays = ['mon', 'tue', 'wed', 'thu', 'fri'];
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _submitPostRide() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter origin and destination')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final payload = {
      'from_address': _fromController.text.trim(),
      'from_lat': 19.0760, // Mumbai default coordinates for demo
      'from_lng': 72.8777,
      'to_address': _toController.text.trim(),
      'to_lat': 19.2183,
      'to_lng': 72.9781,
      'route_points': [
        {'lat': 19.0760, 'lng': 72.8777},
        {'lat': 19.1500, 'lng': 72.9200},
        {'lat': 19.2183, 'lng': 72.9781},
      ],
      'total_seats': _seats,
      'coin_per_seat': _coinPrice,
      'time_type': _timeType,
      'recurring_days': _timeType == 'recurring' ? _selectedDays : null,
    };

    try {
      final res = await _apiService.postRide(payload);
      if (res['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride Posted Successfully! Drivers can now match.')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to post ride')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting ride: $e')),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offer a Ride (Driver Mode)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _fromController,
              decoration: InputDecoration(
                labelText: 'Starting Location (Origin)',
                prefixIcon: const Icon(Icons.my_location, color: AppTheme.accentGreen),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _toController,
              decoration: InputDecoration(
                labelText: 'Destination Location',
                prefixIcon: const Icon(Icons.location_on, color: AppTheme.accentSaffron),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Seats Available', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _seats,
                        items: [1, 2, 3, 4, 5, 6].map((s) => DropdownMenuItem(value: s, child: Text('$s Seats'))).toList(),
                        onChanged: (v) => setState(() => _seats = v!),
                        decoration: InputDecoration(filled: true, fillColor: AppTheme.cardDark, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Coins per Seat', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _coinPrice,
                        items: [5, 10, 15, 20, 25, 50].map((c) => DropdownMenuItem(value: c, child: Text('$c Coins'))).toList(),
                        onChanged: (v) => setState(() => _coinPrice = v!),
                        decoration: InputDecoration(filled: true, fillColor: AppTheme.cardDark, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Departure Schedule', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Row(
              children: [
                FilterChip(selected: _timeType == 'now', label: const Text('Depart Now'), onSelected: (_) => setState(() => _timeType = 'now')),
                const SizedBox(width: 8),
                FilterChip(selected: _timeType == 'scheduled', label: const Text('Scheduled'), onSelected: (_) => setState(() => _timeType = 'scheduled')),
                const SizedBox(width: 8),
                FilterChip(selected: _timeType == 'recurring', label: const Text('Mon-Fri Recurring'), onSelected: (_) => setState(() => _timeType = 'recurring')),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentSaffron),
                onPressed: _isLoading ? null : _submitPostRide,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Post Ride & Earn Coins'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
