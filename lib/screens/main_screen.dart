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

  final Color sppgBlue = const Color(0xFF0056A3); 
  final Color activeColor = const Color(0xFF00D5FF);

  final List<Widget> _pages = [Dashboard(), ScanScreen(), ProfileScreen()];

  Widget _navItem(
    BuildContext context,
    String label,
    IconData icon,
    int index,
  ) {
    bool isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor : sppgBlue.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(15),
            boxShadow: isActive 
              ? [BoxShadow(color: activeColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))] 
              : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon, 
                color: Colors.white, 
                size: isActive ? 30 : 26
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(160, 0, 213, 255),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: sppgBlue,
        ),
        padding: const EdgeInsets.only(left: 12, right: 12, top: 15, bottom: 25),
        child: Row(
          children: [
            _navItem(context, "Beranda", Icons.local_shipping, 0),
            _navItem(context, "Scan", Icons.qr_code_scanner, 1),
            _navItem(context, "Profil", Icons.person_pin, 2),
          ],
        ),
      ),
    );
  }
}