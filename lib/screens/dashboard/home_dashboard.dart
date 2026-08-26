import 'package:corporate_pooling_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../../widgets/core/glass_panel.dart';

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
    // The background (Color + StarRain + Glows) is now provided globally 
    // by AppBackground in main.dart. We just need a transparent Scaffold.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
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
              const SizedBox(height: 80),
            ],
          ),
        ),
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
        _buildStatCard('KarmaCoin', '170', Icons.monetization_on, Colors.amber),
        const SizedBox(width: 12),
        _buildStatCard('Karma', '5.0', Icons.favorite, Colors.redAccent),
        const SizedBox(width: 12),
        _buildStatCard('Current', '1', Icons.two_wheeler, Colors.blueAccent),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: GlassPanel(
        sigma: 8,
        padding: const EdgeInsets.symmetric(vertical: 12),
        borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildFindRidePanel() {
    return _buildGlassPanel(
      borderColor: Colors.deepOrange.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.search_rounded, color: Colors.white70, size: 24),
              SizedBox(width: 8),
              Text(
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
          const Row(
            children: [
              Icon(Icons.directions_car_rounded, color: Colors.white70, size: 24),
              SizedBox(width: 8),
              Text(
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
        const Expanded(child: Divider(color: AppTheme.glassWhite10)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(color: Colors.orange.withValues(alpha: 0.7), fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.glassWhite10)),
      ],
    );
  }

  Widget _buildGlassPanel({required Widget child, required Color borderColor}) {
    return GlassPanel(
      sigma: 8,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      customBorder: Border.all(color: borderColor, width: 1.5),
      opacity: 0.03,
      child: child,
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
          color: Colors.transparent,
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
            side: const BorderSide(color: AppTheme.glassWhite10),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

