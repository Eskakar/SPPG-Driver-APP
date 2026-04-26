import 'package:flutter/material.dart';
import 'package:sppg_driver_app/screens/login_screen.dart';
//import 'package:sppg_driver_app/screens/main_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen()
    );
  }
}
