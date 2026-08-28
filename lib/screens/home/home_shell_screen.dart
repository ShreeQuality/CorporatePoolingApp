import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/my_rides_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/safety_tab.dart';
import 'tabs/wallet_tab.dart';

class HomeShellScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  const HomeShellScreen({super.key, this.arguments});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _selectedTabIndex = 0;

  final List<Widget> _tabs = const [
    DashboardTab(),
    MyRidesTab(),
    WalletTab(),
    SafetyTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true, // Allows content to flow smoothly under the floating bar
      body: IndexedStack(
        index: _selectedTabIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _buildTransparentBottomNav(),
    );
  }

  Widget _buildTransparentBottomNav() {
    const List<_NavItem> items = [
      _NavItem(icon: Icons.home_rounded, label: 'Home', activeColor: Color(0xFFFFB74D)),
      _NavItem(icon: Icons.directions_car_rounded, label: 'Rides', activeColor: Color(0xFF00E5FF)),
      _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Wallet', activeColor: Color(0xFFFFD54F)),
      _NavItem(icon: Icons.shield_rounded, label: 'Safety', activeColor: Color(0xFFFF5252)),
      _NavItem(icon: Icons.person_rounded, label: 'Profile', activeColor: Color(0xFF00E676)),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = _selectedTabIndex == index;
          final item = items[index];
          final color = item.activeColor;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedTabIndex = index);
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.16) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? Border.all(
                        color: color.withValues(alpha: 0.6),
                        width: 1.2,
                      )
                    : Border.all(color: Colors.transparent),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.45),
                          blurRadius: 14,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 23,
                    color: isSelected ? color : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color activeColor;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.activeColor,
  });
}
