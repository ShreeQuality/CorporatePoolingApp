import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/wallet_provider.dart';
import '../../../widgets/core/glass_panel.dart';

class WalletSummaryBanner extends StatelessWidget {
  const WalletSummaryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProv, child) {
        final summary = walletProv.summary;

        return GlassPanel(
          sigma: 10,
          opacity: 0.05,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          borderRadius: BorderRadius.circular(20),
          customBorder: Border.all(
            color: const Color(0xFFFFB74D).withValues(alpha: 0.35),
            width: 1.2,
          ),
          child: Column(
            children: [
              // TOP ROW: Karma Coins & Corporate Grant
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Karma Coins Pill
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFB74D).withValues(alpha: 0.15),
                          border: Border.all(
                            color: const Color(0xFFFFB74D).withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.monetization_on_rounded,
                          color: Color(0xFFFFB74D),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${summary.availableCoins.toStringAsFixed(0)} Coins',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            'Spendable Balance',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFB0BEC5),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Corporate Grant Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.business_rounded,
                          color: Color(0xFF00E5FF),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${summary.corporateGrantRemaining.toStringAsFixed(0)} Grant Left',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF00E5FF),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: AppTheme.glassWhite10, height: 1),
              ),

              // BOTTOM ROW: CO2 Saved & Safety Trust Score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // CO2 Metric
                  Row(
                    children: [
                      const Icon(
                        Icons.eco_rounded,
                        color: Color(0xFF00E676),
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${summary.co2SavedKg.toStringAsFixed(1)} kg CO₂ Saved',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF00E676),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Trust Score Metric
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: Color(0xFFFF5252),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${summary.trustScore.toStringAsFixed(0)}/100 Trust Score',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFFF5252),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
