import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/core/glass_panel.dart';

class MyRidesTab extends StatefulWidget {
  const MyRidesTab({super.key});

  @override
  State<MyRidesTab> createState() => _MyRidesTabState();
}

class _MyRidesTabState extends State<MyRidesTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Commutes',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'LIVE ROSTER',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF00E5FF),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sub-Tabs Header (Active, Upcoming, Recurring, Past)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (_) => HapticFeedback.lightImpact(),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.5)),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Recurring'),
                Tab(text: 'Past'),
              ],
            ),
          ),

          // Tab Views Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEmptyState('No Active Commutes', 'When a driver starts a ride or accepts your booking, it will appear here in real time.', Icons.radar_rounded),
                _buildEmptyState('No Upcoming Commutes', 'You have no confirmed pool bookings scheduled for today or tomorrow.', Icons.calendar_today_rounded),
                _buildEmptyState('No Recurring Commutes', 'Set up a Mon–Fri daily office schedule to pool automatically without manual daily booking.', Icons.repeat_rounded),
                _buildEmptyState('No Past Trip Records', 'Completed commutes and downloadable SEBI ESG carbon certificates will appear here.', Icons.history_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: GlassPanel(
          sigma: 8,
          opacity: 0.03,
          padding: const EdgeInsets.all(24),
          borderRadius: BorderRadius.circular(20),
          customBorder: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF00E5FF).withValues(alpha: 0.6), size: 42),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
