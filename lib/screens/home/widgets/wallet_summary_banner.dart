import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/wallet_provider.dart';

class WalletSummaryBanner extends StatelessWidget {
  const WalletSummaryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProv, child) {
        final summary = walletProv.summary;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x1A00F0FF), // cyanSubtle
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00F0FF), width: 1.0), // cyan
            boxShadow: [
              const BoxShadow(
                color: Color(0x4D00F0FF), // cyanGlow
                blurRadius: 10,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: const Color(0xFF00F0FF).withOpacity(0.15),
                blurRadius: 25,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF00F0FF)),
                  const SizedBox(width: 8),
                  const Text(
                    'KARMA COINS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00F0FF),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  context.push('/wallet');
                },
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFB300), // amber
                      ),
                      alignment: Alignment.center,
                      child: const Text('K', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${summary.availableCoins.toInt()}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Coins',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _SimpleStat(
                    icon: Icons.access_time,
                    value: '${summary.corporateGrantRemaining.toInt()}',
                    label: 'Grant Left',
                    color: const Color(0xFF00F0FF),
                  ),
                  _SimpleStat(
                    icon: Icons.cloud_upload_outlined,
                    value: '${summary.co2SavedKg}kg',
                    label: 'CO2 Saved',
                    color: const Color(0xFF00FF88),
                  ),
                  _SimpleStat(
                    icon: Icons.gpp_good,
                    value: '${summary.trustScore.toInt()}/100',
                    label: 'Trust Score',
                    color: const Color(0xFFFFB300),
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

class _SimpleStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SimpleStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ],
    );
  }
}
