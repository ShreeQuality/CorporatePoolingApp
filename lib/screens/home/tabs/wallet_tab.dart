import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/wallet_provider.dart';
import '../../../widgets/core/glass_panel.dart';

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Consumer<WalletProvider>(
          builder: (context, walletProv, _) {
            final summary = walletProv.summary;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Karma Wallet',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB74D).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFB74D).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '100% CASHLESS',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFFB74D),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Main Balance Card
                GlassPanel(
                  sigma: 10,
                  opacity: 0.05,
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(24),
                  customBorder: Border.all(
                    color: const Color(0xFFFFB74D).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Available Balance',
                        style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12.5),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFB74D), size: 32),
                          const SizedBox(width: 8),
                          Text(
                            summary.availableCoins.toStringAsFixed(0),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Coins',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFFB74D),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppTheme.glassWhite10, height: 1),
                      const SizedBox(height: 14),

                      // 3-Tier Breakdown
                      Row(
                        children: [
                          _buildTierCol('Employer Grant', '${summary.corporateGrantRemaining.toStringAsFixed(0)} Coins', const Color(0xFF00E5FF)),
                          Container(width: 1, height: 32, color: AppTheme.glassWhite10),
                          _buildTierCol('Locked Escrow', '${summary.lockedEscrow.toStringAsFixed(0)} Coins', const Color(0xFFFF5252)),
                          Container(width: 1, height: 32, color: AppTheme.glassWhite10),
                          _buildTierCol('Lifetime Earned', '${summary.lifetimeEarned.toStringAsFixed(0)} Coins', const Color(0xFF00E676)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        title: 'Gift Colleague',
                        subtitle: 'Send Coins to Poolers',
                        icon: Icons.card_giftcard_rounded,
                        color: const Color(0xFF00E5FF),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Colleague Coin Gift sheet opening...')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        title: 'ESG Certificate',
                        subtitle: '${summary.co2SavedKg.toStringAsFixed(1)} kg Saved',
                        icon: Icons.eco_rounded,
                        color: const Color(0xFF00E676),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('SEBI Scope 3 ESG Certificate downloading...')),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Recent Transactions Header
                Text(
                  'Recent Activity Ledger',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                _buildLedgerTile('Morning Commute Escrow', 'Deducted for Manyata Route', '- 24 Coins', isCredit: false),
                const SizedBox(height: 8),
                _buildLedgerTile('Monthly Corporate Grant', 'Infosys Sustainability Allowance', '+ 200 Coins', isCredit: true),
                const SizedBox(height: 8),
                _buildLedgerTile('Detour Appreciation Bonus', 'Pickup at Hebbal Junction', '+ 6 Coins', isCredit: true),

                const SizedBox(height: 110),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTierCol(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 10.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: GlassPanel(
        sigma: 8,
        opacity: 0.03,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: BorderRadius.circular(16),
        customBorder: Border.all(color: color.withValues(alpha: 0.35)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 10.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLedgerTile(String title, String subtitle, String amount, {required bool isCredit}) {
    final color = isCredit ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    return GlassPanel(
      sigma: 6,
      opacity: 0.025,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: BorderRadius.circular(12),
      customBorder: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: GoogleFonts.inter(color: color, fontSize: 13.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
