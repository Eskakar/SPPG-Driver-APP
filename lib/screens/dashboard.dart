import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SPPG Driver App",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}