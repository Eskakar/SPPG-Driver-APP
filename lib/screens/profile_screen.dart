import 'package:flutter/material.dart';
import 'package:sppg_driver_app/screens/splash_screen.dart';
import 'package:sppg_driver_app/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final api = ApiService();

  
  Future<void> checkCookies() async {
    if (!api.isReady) {
      await api.init();
    }
    final cookies = await api.cookieJar.loadForRequest(
      Uri.parse("http://10.0.2.2:3000"),
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
          ],
        ),
      )
    );
  }
}