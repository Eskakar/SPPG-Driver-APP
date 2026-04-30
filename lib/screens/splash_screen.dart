import 'package:flutter/material.dart';
import 'package:sppg_driver_app/screens/login_screen.dart';
import 'package:sppg_driver_app/screens/main_screen.dart';
import 'package:sppg_driver_app/services/api_service.dart';
import 'package:sppg_driver_app/services/biometric_service.dart';
import 'package:sppg_driver_app/services/notification_service.dart';
import 'package:sppg_driver_app/services/secure_storage_service.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final api = ApiService();

  @override
  void initState() {
    super.initState();
    
    checkAuth();
  }

  Future<void> goLogin() async {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> goMainScreen() async {
    // await NotificationService.instance.markAsRead();
    // await NotificationService.instance.fetchAndShowNotif();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  Future<void> checkAuth() async {
    final hasSession = await api.checkSession();
    await NotificationService.instance.fetchAndShowNotif();
    // await NotificationService.instance.markAsRead();
    if(!hasSession){
      goLogin();
      return;
    }
    final biometricEnabled = await SecureStorageService.instance.isBiometricEnabled();
      if (biometricEnabled) {
      final ok = await BiometricService.instance.authenticate();
      if (!ok) {
        goLogin();
        return;
      }
    }
    goMainScreen();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}