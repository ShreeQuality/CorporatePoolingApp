import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/secure_storage_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/core/glass_panel.dart';
import '../widgets/driver_upgrade_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final user = auth.currentUser;
            final fullName = user?.fullName ?? 'Commuter';
            final email = user?.email ?? 'verified@corporate.com';
            final company = user?.companyName ?? 'Verified Corporate';
            final isDriver = user?.isDriver ?? false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [


                // User Identity Card
                GlassPanel(
                  sigma: 10,
                  opacity: 0.05,
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(24),
                  customBorder: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF00E676), width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 36,
                          backgroundColor: Color(0xFF1E293B),
                          child: Icon(Icons.person_rounded, color: Colors.white, size: 42),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Badges Row
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildBadge(company, Icons.business_rounded, const Color(0xFF00E5FF)),
                          _buildBadge('Aadhaar KYC Verified', Icons.verified_rounded, const Color(0xFF00E676)),
                          if (isDriver)
                            _buildBadge('Verified Driver', Icons.drive_eta_rounded, const Color(0xFFFFB74D))
                          else
                            _buildBadge('Pure Rider', Icons.directions_walk_rounded, Colors.white70),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Driver Upgrade Card if not driver
                if (!isDriver) ...[
                  const DriverUpgradeCard(),
                  const SizedBox(height: 16),
                ],

                // Settings & Preferences
                Text(
                  'Account & Preferences',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                _buildSettingsTile('Corporate Email Re-verification', Icons.domain_verification_rounded, () {}),
                const SizedBox(height: 8),
                _buildSettingsTile('Vehicles & Driving Documents', Icons.directions_car_filled_rounded, () {
                  context.push('/driver-kyc');
                }),
                const SizedBox(height: 8),
                _buildSettingsTile('App Notification Preferences', Icons.notifications_active_rounded, () {}),
                const SizedBox(height: 8),
                _buildSettingsTile('Data Privacy & DPDP Consent', Icons.privacy_tip_rounded, () {}),

                const SizedBox(height: 20),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      await SecureStorageService.clearAll();
                      if (context.mounted) {
                        context.go('/phone-login');
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF5252), size: 18),
                    label: Text(
                      'Log Out',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFF5252),
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5252).withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: const Color(0xFFFF5252).withValues(alpha: 0.4)),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 110),
              ],
            );
          },
        ),
      ),
    ),
  );
}

  Widget _buildBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: GlassPanel(
        sigma: 6,
        opacity: 0.025,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: BorderRadius.circular(14),
        customBorder: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00E5FF), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.35),
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}
