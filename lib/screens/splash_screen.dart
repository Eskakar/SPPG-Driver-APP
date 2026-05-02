import 'package:flutter/material.dart';
import 'package:sppg_driver_app/screens/error_screen.dart';
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
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }
  void goError() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ErrorScreen(),
      ),
    );
  }

  Future<void> checkAuth() async {
    try{final hasSession = await api.checkSession().timeout(const Duration(seconds: 5));

      if (!hasSession) {
        goLogin();
        return;
      }

      //  biometric
      final biometricEnabled =
          await SecureStorageService.instance.isBiometricEnabled();

      if (biometricEnabled) {
        final ok = await BiometricService.instance.authenticate();
        if (!ok) {
          goLogin();
          return;
        }
      }

      // ambil notif SETELAH login valid
      await NotificationService.instance.fetchAndShowNotif();

      goMainScreen();
    }catch(e){
      goError();
    }
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