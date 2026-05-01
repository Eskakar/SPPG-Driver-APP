import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:ui';
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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final api = ApiService();
  bool isLoading = false;
  bool isBiometricAvailable = false;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    // Inisialisasi animasi DULU sebelum apapun yang bisa trigger setState
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();

    // Panggil setelah animasi siap
    initBiometricState();
  }

  @override
  void dispose() {
    _animController.dispose();
    namaController.dispose();
    passwordController.dispose();
    super.dispose();
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
        options: Options(validateStatus: (_) => true),
      );

      if (response.data["success"] == true) {
        await NotificationService.instance.fetchAndShowNotif();
        if (!mounted) return;
        _biometricOffer();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        if (!mounted) return;
        final message = response.data["message"] ?? "Login gagal";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? "Login gagal";
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _biometric() async {
    final hasSession = await api.checkSession();

    if (!hasSession) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session tidak ditemukan, silakan login dulu"),
          behavior: SnackBarBehavior.floating,
        ),
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

  Future<void> _biometricOffer() async {
    final biometricAvailable = await BiometricService.instance.isAvailable();
    if (biometricAvailable) {
      await SecureStorageService.instance.setBiometricEnabled(true);
    }
  }

  Future<void> initBiometricState() async {
    final biometricEnabled = await SecureStorageService.instance
        .isBiometricEnabled();
    if (!biometricEnabled) {
      setState(() => isBiometricAvailable = false);
      return;
    }
    final hasSession = await api.checkSession();
    setState(() => isBiometricAvailable = hasSession);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background: logo image + blur ──
          Image.asset('assets/logo_sppg.png', fit: BoxFit.cover),
          // Dark overlay agar teks tetap terbaca
          Container(color: Colors.black.withAlpha(140)),
          // Blur layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(color: Colors.transparent),
          ),

          // ── Content ──
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      // App name
                      const Text(
                        "SPPG Driver",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Masuk untuk melanjutkan",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 0.3,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // ── Card Form ──
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(33),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withAlpha(64),
                                width: 1.2,
                              ),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama field
                                _glassLabel("Nama Pengguna"),
                                const SizedBox(height: 8),
                                _glassTextField(
                                  controller: namaController,
                                  hint: "Masukkan email atau nama",
                                  icon: Icons.person_outline_rounded,
                                ),

                                const SizedBox(height: 20),

                                // Password field
                                _glassLabel("Password"),
                                const SizedBox(height: 8),
                                _glassTextField(
                                  controller: passwordController,
                                  hint: "Masukkan password",
                                  icon: Icons.lock_outline_rounded,
                                  obscure: _obscurePassword,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Login button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1A237E),
                                      disabledBackgroundColor: Colors.white
                                          .withAlpha(102),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Color(0xFF1A237E),
                                            ),
                                          )
                                        : const Text(
                                            "Masuk",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Biometric ──
                      if (isBiometricAvailable)
                        Column(
                          children: [
                            Text(
                              "atau gunakan",
                              style: TextStyle(
                                color: Colors.white.withAlpha(153),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _biometric,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withAlpha(38),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(89),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.fingerprint_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Login dengan Biometrik",
                              style: TextStyle(
                                color: Colors.white.withAlpha(153),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      else
                        Opacity(
                          opacity: 0.3,
                          child: Column(
                            children: [
                              const Icon(
                                Icons.fingerprint_rounded,
                                color: Colors.white,
                                size: 34,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Biometrik",
                                style: TextStyle(
                                  color: Colors.white.withAlpha(128),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withAlpha(217),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _glassTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(51), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withAlpha(102),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: Colors.white60, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
