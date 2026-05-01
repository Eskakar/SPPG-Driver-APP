import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sppg_driver_app/screens/dashboard.dart';
import 'package:sppg_driver_app/screens/profile_screen.dart';
import 'package:sppg_driver_app/screens/scan_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [Dashboard(), ScanScreen(), ProfileScreen()];

  final List<_NavItemData> _navItems = const [
    _NavItemData(
      label: "Dashboard",
      icon: Icons.dashboard_rounded,
      activeColor: Color(0xFF4CAF50),
    ),
    _NavItemData(
      label: "Scan",
      icon: Icons.qr_code_scanner_rounded,
      activeColor: Color(0xFF2196F3),
    ),
    _NavItemData(
      label: "Profile",
      icon: Icons.person_rounded,
      activeColor: Color(0xFFE53935),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true, // konten meluas ke bawah navbar
      body: _pages[_currentIndex],
      bottomNavigationBar: _glassNavBar(),
    );
  }

  Widget _glassNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0x33000000), // hitam ~20%
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0x40FFFFFF), width: 1),
            ),
            child: Row(
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final isActive = _currentIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive
                            ? item.activeColor.withAlpha(220)
                            : const Color(0x00000000),
                        borderRadius: BorderRadius.circular(20),
                        border: isActive
                            ? Border.all(
                                color: const Color(0x40FFFFFF),
                                width: 1,
                              )
                            : null,
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: item.activeColor.withAlpha(100),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: isActive
                                ? Colors.white
                                : const Color(0xAAFFFFFF),
                            size: 22,
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : const Color(0xAAFFFFFF),
                              fontSize: isActive ? 12 : 11,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final Color activeColor;
  const _NavItemData({
    required this.label,
    required this.icon,
    required this.activeColor,
  });
}
