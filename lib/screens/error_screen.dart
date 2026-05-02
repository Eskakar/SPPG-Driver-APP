import 'package:flutter/material.dart';
import 'package:sppg_driver_app/screens/splash_screen.dart';
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.signal_wifi_connected_no_internet_4_rounded),
            const Text("Tidak dapat terhubung ke server"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                );
              },
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      ),
    );
  }
}