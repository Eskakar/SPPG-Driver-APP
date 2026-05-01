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

  Widget _navItem(
    BuildContext context,
    String label,
    IconData icon,
    Color bgColor,
    int index,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: _currentIndex == index ? bgColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
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
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _navItem(context, "Dashboard", Icons.dashboard, Colors.green, 0),
            _navItem(context, "Scan", Icons.qr_code_scanner, Colors.blue, 1),
            _navItem(context, "Profile", Icons.person, Colors.red, 2),
          ],
        ),
      ),
    );
  }
}
