import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../widgets/wallet_summary_banner.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String _selectedFindVehicle = 'Any';
  String _selectedGiveVehicle = 'Car';

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
            const SizedBox(height: 16),

            // Find a Ride Section
            _buildFindRidePanel(),

            const SizedBox(height: 24),

            // Give a Ride Section
            _buildGiveRidePanel(),

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
                Row(
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF00E5FF),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '[ $company ]',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildFindRidePanel() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.10),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.38),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find a Ride',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD54F),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Text(
                '"Give a ride today, take a ride tomorrow"',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.9),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildVehicleSelector('Any', Icons.directions_car_rounded, _selectedFindVehicle == 'Any', (v) => setState(() => _selectedFindVehicle = v)),
                _buildVehicleSelector('Bike', Icons.two_wheeler_rounded, _selectedFindVehicle == 'Bike', (v) => setState(() => _selectedFindVehicle = v)),
                _buildVehicleSelector('Scooter', Icons.electric_scooter_rounded, _selectedFindVehicle == 'Scooter', (v) => setState(() => _selectedFindVehicle = v)),
                _buildVehicleSelector('Auto', Icons.electric_rickshaw_rounded, _selectedFindVehicle == 'Auto', (v) => setState(() => _selectedFindVehicle = v)),
              ],
            ),
            const SizedBox(height: 18),
            _buildActionButton('Find rides near me', Icons.search_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildGiveRidePanel() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.10),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00E676).withValues(alpha: 0.38),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Give a Ride',
              style: GoogleFonts.outfit(
                color: const Color(0xFF00E676),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF00E676).withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Text(
                '"Give a ride today, take a ride tomorrow"',
                style: GoogleFonts.inter(
                  color: const Color(0xFF00E676).withValues(alpha: 0.9),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildVehicleSelector('Bike', Icons.two_wheeler_rounded, _selectedGiveVehicle == 'Bike', (v) => setState(() => _selectedGiveVehicle = v)),
                _buildVehicleSelector('Scooter', Icons.electric_scooter_rounded, _selectedGiveVehicle == 'Scooter', (v) => setState(() => _selectedGiveVehicle = v)),
                _buildVehicleSelector('Auto', Icons.electric_rickshaw_rounded, _selectedGiveVehicle == 'Auto', (v) => setState(() => _selectedGiveVehicle = v)),
                _buildVehicleSelector('Car', Icons.directions_car_rounded, _selectedGiveVehicle == 'Car', (v) => setState(() => _selectedGiveVehicle = v)),
              ],
            ),
            const SizedBox(height: 18),
            _buildActionButton('Post my route', Icons.add_road_rounded, isDriver: true),
          ],
        ),
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
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD54F).withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD54F)
                : Colors.white.withValues(alpha: 0.22),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFFD54F) : Colors.white,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? const Color(0xFFFFD54F) : Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, {bool isDriver = false}) {
    final gradient = isDriver
        ? const LinearGradient(
            colors: [Color(0xFF69F0AE), Color(0xFF00E676)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFE082), // Radiant Champagne Top
              Color(0xFFFFB300), // Rich Warm Amber Gold
              Color(0xFFFF8F00), // Deep Amber Rim
            ],
          );

    final glowColor = isDriver ? const Color(0xFF00E676) : const Color(0xFFFFB300);
    final textColor = isDriver ? const Color(0xFF0A2E17) : const Color(0xFF2E1C0C);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E293B),
            content: Text('$label initialized! Connecting to live routes...'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.45),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
