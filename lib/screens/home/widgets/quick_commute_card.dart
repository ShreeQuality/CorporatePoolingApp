import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/core/glass_panel.dart';

class QuickCommuteCard extends StatelessWidget {
  final VoidCallback? onTap;
  const QuickCommuteCard({super.key, this.onTap});

  bool get _isMorning {
    final hour = DateTime.now().hour;
    return hour >= 4 && hour < 14;
  }

  @override
  Widget build(BuildContext context) {
    final title = _isMorning ? 'Morning Commute' : 'Evening Return Commute';
    final subtitle = _isMorning
        ? 'Quick 1-Tap Pool to Manyata Tech Park Block D'
        : 'Quick 1-Tap Pool Return Ride Home';
    final icon = _isMorning ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;
    final accentColor = _isMorning ? const Color(0xFFFFB74D) : const Color(0xFF00E5FF);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (onTap != null) {
          onTap!();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1E293B),
              content: Text(
                'Searching routes for $title...',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: GlassPanel(
        sigma: 8,
        opacity: 0.04,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: BorderRadius.circular(16),
        customBorder: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '1-TAP',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF00E676),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.4),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
