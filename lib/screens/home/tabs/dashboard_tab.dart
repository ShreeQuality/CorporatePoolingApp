import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../../../widgets/core/glass_panel.dart';
import '../widgets/driver_upgrade_card.dart';
import '../widgets/quick_commute_card.dart';
import '../widgets/wallet_summary_banner.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String _selectedFindVehicle = 'Any';
  String _selectedGiveVehicle = 'Car';
  int _activeModeIndex = 0; // 0 = Find a Ride, 1 = Give a Ride

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchSummary();
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            const WalletSummaryBanner(),
            const SizedBox(height: 14),
            const QuickCommuteCard(),
            const SizedBox(height: 14),

            // Driver Upgrade CTA if user is not yet a registered driver
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final isDriver = auth.currentUser?.isDriver ?? false;
                if (!isDriver) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 14.0),
                    child: DriverUpgradeCard(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Mode Selector Tabs (Find a Ride vs Give a Ride)
            _buildModeSwitcher(),
            const SizedBox(height: 16),

            // Active Mode Panel
            if (_activeModeIndex == 0) _buildFindRidePanel() else _buildGiveRidePanel(),

            const SizedBox(height: 110), // clearance for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final userName = auth.currentUser?.fullName ?? 'Commuter';
        final company = auth.currentUser?.companyName ?? 'Verified Corporate';
        final initials = _getInitials(userName);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                Text(
                  userName,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.business_rounded, color: Color(0xFF00E5FF), size: 11),
                      const SizedBox(width: 4),
                      Text(
                        company,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF00E5FF),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications center opening...')),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF1E293B),
                    child: Text(
                      initials,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              index: 0,
              label: 'Find a Ride',
              icon: Icons.search_rounded,
              color: const Color(0xFFFFB74D),
            ),
          ),
          Expanded(
            child: _buildModeTab(
              index: 1,
              label: 'Give a Ride',
              icon: Icons.directions_car_rounded,
              color: const Color(0xFF00E676),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required int index,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _activeModeIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _activeModeIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: color.withValues(alpha: 0.5), width: 1)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.white60, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFindRidePanel() {
    return GlassPanel(
      sigma: 8,
      opacity: 0.03,
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(20),
      customBorder: Border.all(color: const Color(0xFFFFB74D).withValues(alpha: 0.4), width: 1.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Color(0xFFFFB74D), size: 20),
              const SizedBox(width: 8),
              Text(
                'Commuter Search & Match',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Find empty seats on verified corporate commuter routes.',
            style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildVehicleSelector('Any', Icons.near_me_rounded, _selectedFindVehicle == 'Any', (v) => setState(() => _selectedFindVehicle = v)),
              _buildVehicleSelector('Bike', Icons.two_wheeler_rounded, _selectedFindVehicle == 'Bike', (v) => setState(() => _selectedFindVehicle = v)),
              _buildVehicleSelector('Scooter', Icons.electric_scooter_rounded, _selectedFindVehicle == 'Scooter', (v) => setState(() => _selectedFindVehicle = v)),
              _buildVehicleSelector('Auto', Icons.local_taxi_rounded, _selectedFindVehicle == 'Auto', (v) => setState(() => _selectedFindVehicle = v)),
            ],
          ),
          const SizedBox(height: 18),
          _buildActionButton('Find rides near me', Icons.search_rounded, const Color(0xFFFFB74D)),
        ],
      ),
    );
  }

  Widget _buildGiveRidePanel() {
    return GlassPanel(
      sigma: 8,
      opacity: 0.03,
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(20),
      customBorder: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4), width: 1.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alt_route_rounded, color: Color(0xFF00E676), size: 20),
              const SizedBox(width: 8),
              Text(
                'Publish Your Commute Corridor',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Share empty seats, offset fuel costs, and earn Karma Coins.',
            style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildVehicleSelector('Bike', Icons.two_wheeler_rounded, _selectedGiveVehicle == 'Bike', (v) => setState(() => _selectedGiveVehicle = v)),
              _buildVehicleSelector('Scooter', Icons.electric_scooter_rounded, _selectedGiveVehicle == 'Scooter', (v) => setState(() => _selectedGiveVehicle = v)),
              _buildVehicleSelector('Auto', Icons.local_taxi_rounded, _selectedGiveVehicle == 'Auto', (v) => setState(() => _selectedGiveVehicle = v)),
              _buildVehicleSelector('Car', Icons.directions_car_rounded, _selectedGiveVehicle == 'Car', (v) => setState(() => _selectedGiveVehicle = v)),
            ],
          ),
          const SizedBox(height: 18),
          _buildActionButton('Post my route', Icons.add_road_rounded, const Color(0xFF00E676)),
        ],
      ),
    );
  }

  Widget _buildVehicleSelector(String label, IconData icon, bool isSelected, Function(String) onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white60, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color accentColor) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1E293B),
              content: Text('$label initialized! Connecting to live routes...'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        icon: Icon(icon, color: Colors.black87, size: 18),
        label: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }
}
