import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:sppg_driver_app/screens/main_screen.dart';
import 'package:sppg_driver_app/services/api_service.dart';
import 'package:sppg_driver_app/services/biometric_service.dart';
import 'package:sppg_driver_app/services/notification_service.dart';
import 'package:sppg_driver_app/services/secure_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final api = ApiService();
  bool isLoading = false; 
  bool isBiometricAvailable = false;
  @override
  void initState() {
    super.initState();
    initBiometricState();
  }

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final response = await api.dio.post(
        "/auth/login",
        data: {
          "nama": namaController.text,
          "password": passwordController.text,
        },
        //menghindari error 401
        options: Options (validateStatus: (_) => true)
      );

      if (response.data["success"] == true) {
        await NotificationService.instance.fetchAndShowNotif();
        if (!mounted) return;
        _biometricOffer();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen())
        );
      } 
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? "Login gagal";
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }finally {
      setState(() => isLoading = false);
    }
  }
  Future<void> _biometric() async {
    final hasSession = await api.checkSession();

    if (!hasSession) {
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Session tidak ditemukan, silakan login dulu")),
      );
      return;
    }

    if (isBiometricAvailable) {
      final ok = await BiometricService.instance.authenticate();

      if (ok) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    }
  }
  Future<void> _biometricOffer() async{
    //check apakah ada biometric di hp
    final biometricAvailable = await BiometricService.instance.isAvailable();
    if (biometricAvailable) {
      //menyalakan fitur bimetric di app
      await SecureStorageService.instance.setBiometricEnabled(true);
    }
  }
  Future<void> initBiometricState() async {
    //apakah biometric untuk app di enable
    final biometricEnabled = await SecureStorageService.instance.isBiometricEnabled();

    if (!biometricEnabled) {
      setState(() => isBiometricAvailable = false);
      return;
    }
    final hasSession = await api.checkSession();
    setState(() {
      isBiometricAvailable = hasSession;
    });
  }

  @override
  void dispose() {
    namaController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: login,
                child: const Text("Login"),
              ),
            ),
            const SizedBox(height: 15),
            IconButton(
              onPressed: isBiometricAvailable? () async {
                      await _biometric();
                    } : null, 
              icon: Icon(
                Icons.fingerprint_outlined,
                color: isBiometricAvailable ? Colors.blue : Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }
}