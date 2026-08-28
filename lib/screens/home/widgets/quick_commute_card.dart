import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
        ? 'Manyata Tech Park Block D'
        : 'Return Ride Home';

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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E293B).withValues(alpha: 0.7),
                const Color(0xFF0F172A).withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF94A3B8),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Glowing Neon Emerald [ 1-TAP ] Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E676).withValues(alpha: 0.6),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  '1-TAP',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0A2E17),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
