import 'package:flutter/material.dart';
import 'package:sppg_driver_app/screens/splash_screen.dart';
import 'package:sppg_driver_app/services/api_service.dart';
import 'package:dio/dio.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final api = ApiService();
  bool isScanning = false;
  Future<void> checkCookies() async {
    if (!api.isReady) {
      await api.init();
    }
    final cookies = await api.cookieJar.loadForRequest(
      Uri.parse(api.baseUrl),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(cookies.isEmpty
          ? "Cookie kosong ❌"
          : "Cookie ada: ${cookies.first.name}")),
    );
  }
  Future<void> checkSession() async {
    if (!api.isReady) {
      await api.init();
    }
    try {
      final res = await api.dio.get("/auth/me");
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Session OK ✅")),
      );

      print(res.data);
    } catch (e) {
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Session gagal ❌")),
      );
    }
  }

  Future<void> logout() async {
    try{
      await api.dio.post("/auth/logout");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout")),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (Route<dynamic> route) => false,
      );
    }catch(_){
      
    }
  }

  Future<void> debugScan() async {
    setState(() => isScanning = true);

    try {
      final res = await ApiService().dio.post(
        "/tugas/scan",
        data: {
          "qr_code": "RUN-4",
          "latitude": -6.2100,
          "longitude": 106.8100,
        },
        options: Options (validateStatus: (_) => true)
      );

      final data = res.data;

      if (!mounted) return;

      // 🔥 HANDLE SUCCESS / ERROR
      if (data["success"] == true) {
        final result = data["data"];

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              result["type"] == "pickup"
                  ? "Pickup Berhasil"
                  : "Berhasil Dikirim",
            ),
            content: Text(result["message"]),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => isScanning = false);
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );

        setState(() => isScanning = false);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

      setState(() => isScanning = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 20,
        title: Text("Profile",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: checkCookies,
              child: const Text("Cek Cookie"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: checkSession,
              child: const Text("Cek Session (/me)"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: logout,
              child: const Text("Logout"),
            ),
            ElevatedButton(
            onPressed: () async {
              await debugScan();
            },
            child: const Text("Debug Scan RUN-4"),
          ),
          ],
        ),
      )
    );
  }
}