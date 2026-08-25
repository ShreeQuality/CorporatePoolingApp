import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/star_rain_1.dart';

class HomeDashboard extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  const HomeDashboard({super.key, this.arguments});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  String _selectedFindVehicle = 'Any';
  String _selectedGiveVehicle = 'Car';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      body: Stack(
        children: [
          // 1. Layer 1: Live Stardust Rainfall Animation (Matching Screen 2)
          const Positioned.fill(
            child: StarRain1(),
          ),

          // 2. Layer 2: Subtle Ambient Light Glows (Matching Screen 2)
          Positioned(
            top: size.height * 0.10,
            left: size.width * 0.1,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withValues(alpha: 0.08),
                    const Color(0xFF6C63FF).withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Foreground Glass UI
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildFindRidePanel(),
                  const SizedBox(height: 16),
                  _buildDividerOR(),
                  const SizedBox(height: 16),
                  _buildGiveRidePanel(),
                  const SizedBox(height: 80), // Padding for bottom nav (which will be added in layout shell later)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning,',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const Text(
              'Ram Hanuman',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              onPressed: () {},
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Text('RH', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(Icons.monetization_on, Colors.amber, '170', 'KarmaCoin')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.favorite, Colors.redAccent, '5.0', 'Karma')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.two_wheeler, Colors.blueAccent, '1', 'Current')),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, Color iconColor, String value, String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFindRidePanel() {
    return _buildGlassPanel(
      borderColor: Colors.deepOrange.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search_rounded, color: Colors.white70, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Find a Ride',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Post your route, earn coins.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
          ),
          const SizedBox(height: 16),
          _buildInspirationalQuote(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildVehicleSelector('Any', Icons.near_me, _selectedFindVehicle == 'Any', (v) => setState(() => _selectedFindVehicle = v)),
              _buildVehicleSelector('Bike', Icons.pedal_bike, _selectedFindVehicle == 'Bike', (v) => setState(() => _selectedFindVehicle = v)),
              _buildVehicleSelector('Scooter', Icons.electric_scooter, _selectedFindVehicle == 'Scooter', (v) => setState(() => _selectedFindVehicle = v)),
              _buildVehicleSelector('Auto', Icons.local_taxi, _selectedFindVehicle == 'Auto', (v) => setState(() => _selectedFindVehicle = v)),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionButton('Find rides near me', Icons.search, Colors.deepOrange.withValues(alpha: 0.15)),
        ],
      ),
    );
  }

  Widget _buildGiveRidePanel() {
    return _buildGlassPanel(
      borderColor: Colors.greenAccent.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car_rounded, color: Colors.white70, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Give a Ride',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Post your route, earn coins.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
          ),
          const SizedBox(height: 16),
          _buildInspirationalQuote(color: Colors.greenAccent),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildVehicleSelector('Bike', Icons.motorcycle, _selectedGiveVehicle == 'Bike', (v) => setState(() => _selectedGiveVehicle = v)),
              _buildVehicleSelector('Scooter', Icons.electric_scooter, _selectedGiveVehicle == 'Scooter', (v) => setState(() => _selectedGiveVehicle = v)),
              _buildVehicleSelector('Auto', Icons.local_taxi, _selectedGiveVehicle == 'Auto', (v) => setState(() => _selectedGiveVehicle = v)),
              _buildVehicleSelector('Car', Icons.directions_car, _selectedGiveVehicle == 'Car', (v) => setState(() => _selectedGiveVehicle = v)),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionButton('Post my route', Icons.add, Colors.greenAccent.withValues(alpha: 0.15)),
        ],
      ),
    );
  }

  Widget _buildDividerOR() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(color: Colors.orange.withValues(alpha: 0.7), fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
      ],
    );
  }

  Widget _buildGlassPanel({required Widget child, required Color borderColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInspirationalQuote({Color color = Colors.orangeAccent}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '"Give a ride today. Someone will help you tomorrow."',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color.withValues(alpha: 0.8),
          fontStyle: FontStyle.italic,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildVehicleSelector(String label, IconData icon, bool isSelected, Function(String) onTap) {
    return GestureDetector(
      onTap: () => onTap(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white.withValues(alpha: 0.5) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color bgColor) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label clicked! (API not wired yet)')),
          );
        },
        icon: Icon(icon, color: Colors.white70, size: 18),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
