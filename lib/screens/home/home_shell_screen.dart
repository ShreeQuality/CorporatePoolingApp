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
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.directions_car_rounded, label: 'Rides'),
      _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
      _NavItem(icon: Icons.shield_rounded, label: 'Safety'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = _selectedTabIndex == index;
          final item = items[index];

          Color activeColor = const Color(0xFF00E5FF);
          if (index == 0) activeColor = const Color(0xFFFFB74D); // Home = Gold
          if (index == 1) activeColor = const Color(0xFF00E5FF); // Rides = Cyan
          if (index == 2) activeColor = const Color(0xFFFFB74D); // Wallet = Gold
          if (index == 3) activeColor = const Color(0xFFFF5252); // Safety = Red
          if (index == 4) activeColor = const Color(0xFF00E676); // Profile = Emerald

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedTabIndex = index);
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: isSelected
                    ? Border.all(
                        color: activeColor.withValues(alpha: 0.5),
                        width: 1.0,
                      )
                    : Border.all(color: Colors.transparent),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 22,
                    color: isSelected ? activeColor : Colors.white60,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.white60,
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
  const _NavItem({required this.icon, required this.label});
}
