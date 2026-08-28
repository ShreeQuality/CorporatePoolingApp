import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/wallet_provider.dart';

class WalletSummaryBanner extends StatelessWidget {
  const WalletSummaryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProv, child) {
        final summary = walletProv.summary;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            // Ambient Multi-Layer Backlight Glow (Nebula Aura)
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFFFFB74D).withValues(alpha: 0.08),
                blurRadius: 20,
                spreadRadius: -4,
                offset: const Offset(-8, -4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              // Frosted Glass Dark Surface with subtle angle gradient
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E293B).withValues(alpha: 0.75),
                  const Color(0xFF0F172A).withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                // Top Subtitle Label
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFFFD54F),
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Karma Coins',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFFD54F),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Main Coin Value Row with 3D Embossed (K) Medallion
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // 3D Embossed Golden Coin Medallion
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFE082), // Champagne Top
                                Color(0xFFFFA000), // Rich Gold
                                Color(0xFFFF6F00), // Deep Amber Rim
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFFFF9C4),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'K',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF3E2723),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${summary.availableCoins.toStringAsFixed(0)} Coins',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD54F),
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Bottom 3 Saturated Highlight Pills
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. Corporate Grant Left Pill (Cyan)
                    _buildPill(
                      icon: Icons.access_time_filled_rounded,
                      label: '${summary.corporateGrantRemaining.toStringAsFixed(0)} Grant Left',
                      color: const Color(0xFF00E5FF),
                      bgColor: const Color(0xFF00E5FF).withValues(alpha: 0.16),
                      borderColor: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                    ),

                    // 2. CO2 Saved Pill (Emerald Green)
                    _buildPill(
                      icon: Icons.eco_rounded,
                      label: '${summary.co2SavedKg.toStringAsFixed(1)} kg',
                      sublabel: 'CO₂ Saved',
                      color: const Color(0xFF00E676),
                      bgColor: const Color(0xFF00E676).withValues(alpha: 0.14),
                      borderColor: const Color(0xFF00E676).withValues(alpha: 0.4),
                    ),

                    // 3. Trust Score Pill (Coral Red Shield)
                    _buildPill(
                      icon: Icons.shield_rounded,
                      label: '${summary.trustScore.toStringAsFixed(0)}/100',
                      sublabel: 'Trust Score',
                      color: const Color(0xFFFF5252),
                      bgColor: const Color(0xFFFF5252).withValues(alpha: 0.14),
                      borderColor: const Color(0xFFFF5252).withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    String? sublabel,
    required Color color,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (sublabel != null)
                Text(
                  sublabel,
                  style: GoogleFonts.inter(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
