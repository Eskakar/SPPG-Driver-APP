import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:sppg_driver_app/services/api_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late ApiService api;
  @override
  void initState() {
    super.initState();
    api = ApiService();
  }
  
  Future<void> checkCookies() async {
    if (!api.isReady) {
      await api.init();
    }
    final cookies = await api.cookieJar.loadForRequest(
      Uri.parse("http://10.0.2.2:3000"),
    );

    print("COOKIES: $cookies");

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
      final res = await api.dio.get("/me");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Session OK ✅")),
      );

      print(res.data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Session gagal ❌")),
      );
    }
  }

  Future<void> logout() async {
    await api.dio.post("/logout");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logout")),
    );
  }
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