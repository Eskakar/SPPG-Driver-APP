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

  final List<Widget> _pages = [
    Dashboard(),
    ScanScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 111, 0),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}