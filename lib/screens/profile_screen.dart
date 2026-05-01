import 'package:flutter/material.dart';
import 'package:sppg_driver_app/screens/notification_screen.dart';
import 'package:sppg_driver_app/screens/splash_screen.dart';
import 'package:sppg_driver_app/services/api_service.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final api = ApiService();
  Map? user;
  bool isLoading = true;

  // Roulette
  late AnimationController _rouletteController;
  late Animation<double> _rouletteAnimation;
  bool isSpinning = false;
  String rouletteResult = "";
  double _currentAngle = 0;
  int _targetIndex = 0;

  // Currency
  final TextEditingController _currencyController = TextEditingController();
  String _convertedResult = "";
  String _selectedCurrency = "USD";
  final Map<String, double> _rates = {
    "USD": 0.000058,
    "EUR": 0.000049,
    "SGD": 0.000074,
    "MYR": 0.00023,
    "JPY": 0.0091,
  };

  final List<String> _rouletteItems = [
    "MOTOR! 🎉",
    "5K 😂",
    "10K 😂",
    "20K 😂",
    "100K 😊",
    "500K ⭐",
    "Coba lagi 😅",
  ];

  // Probabilitas tiap item
  final List<double> _rouletteProbabilities = [
    0.01, // MOTOR! 🎉
    0.20, // 5K 😂
    0.20, // 10K 😂
    0.15, // 20K 😂
    0.10, // 100K 😊
    0.04, // 500K ⭐
    0.30, // Coba lagi 😅
  ];

  // Weighted random
  int _weightedRandom() {
    final random = Random();
    final roll = random.nextDouble(); // 0.0 - 1.0
    double cumulative = 0.0;
    for (int i = 0; i < _rouletteProbabilities.length; i++) {
      cumulative += _rouletteProbabilities[i];
      if (roll < cumulative) return i;
    }
    return _rouletteProbabilities.length - 1; // fallback
  }

  @override
  void initState() {
    super.initState();
    fetchUser();

    _rouletteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _rouletteAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _rouletteController, curve: Curves.decelerate),
    );

    _rouletteController.addListener(() {
      setState(() {
        _currentAngle = _rouletteAnimation.value;
      });
    });

    _rouletteController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isSpinning = false;
          rouletteResult = _rouletteItems[_targetIndex];
        });
      }
    });
  }

  @override
  void dispose() {
    _rouletteController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> fetchUser() async {
    try {
      final res = await api.dio.get("/user/me");
      setState(() {
        user = res.data["data"];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    try {
      await api.dio.post("/auth/logout");
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (_) {}
  }

  void _spinRoulette() {
    if (isSpinning) return;

    _targetIndex = _weightedRandom();

    final segmentAngle = 2 * pi / _rouletteItems.length;

    final middleOfTargetSegment =
        _targetIndex * segmentAngle + segmentAngle / 2;
    final angleToStop = (2 * pi - middleOfTargetSegment) % (2 * pi);
    final totalAngle = (6 * 2 * pi) + angleToStop;

    setState(() {
      isSpinning = true;
      rouletteResult = "";
      _currentAngle = 0;
    });

    _rouletteController.reset();

    _rouletteAnimation = Tween<double>(begin: 0, end: totalAngle).animate(
      CurvedAnimation(parent: _rouletteController, curve: Curves.decelerate),
    );

    _rouletteController.forward();
  }

  void _convertCurrency() {
    final input = double.tryParse(_currencyController.text);
    if (input == null) {
      setState(() => _convertedResult = "Masukkan angka yang valid");
      return;
    }
    final rate = _rates[_selectedCurrency] ?? 1;
    final result = input * rate;
    setState(() {
      _convertedResult =
          "Rp ${_currencyController.text} = ${result.toStringAsFixed(4)} $_selectedCurrency";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _profileCard(),
                    const SizedBox(height: 16),
                    _menuCard(
                      icon: Icons.history,
                      color: Colors.blue,
                      title: "History Tugas",
                      subtitle: "Lihat riwayat pengiriman",
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    _menuCard(
                      icon: Icons.notifications,
                      color: Colors.orange,
                      title: "Notifikasi",
                      subtitle: "Lihat notifikasi masuk",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _currencyCard(),
                    const SizedBox(height: 10),
                    _rouletteCard(),
                    const SizedBox(height: 10),
                    _menuCard(
                      icon: Icons.logout,
                      color: Colors.red,
                      title: "Logout",
                      subtitle: "Keluar dari akun",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Konfirmasi Logout"),
                            content: const Text(
                              "Apakah kamu yakin ingin logout?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  logout();
                                },
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  // ========================
  // PROFILE CARD
  // ========================
  Widget _profileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              image: DecorationImage(
                image: user != null && user!["foto_profil"] != null
                    ? NetworkImage(user!["foto_profil"])
                    : const AssetImage("assets/profile.png") as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?["nama"] ?? "Nama",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?["no_telp"] ?? "-",
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user?["role"] ?? "-",
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Gaji: Rp ${user?["gaji"] ?? 0}",
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // MENU CARD
  // ========================
  Widget _menuCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ========================
  // CURRENCY CARD
  // ========================
  Widget _currencyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.currency_exchange,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                "Konversi Mata Uang",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _currencyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Jumlah (Rp)",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedCurrency,
                items: _rates.keys
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedCurrency = val!);
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _convertCurrency,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Convert"),
              ),
            ],
          ),
          if (_convertedResult.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _convertedResult,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ========================
  // ROULETTE CARD
  // ========================
  Widget _rouletteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.casino, color: Colors.purple, size: 24),
              ),
              const SizedBox(width: 14),
              const Text(
                "Mini Game Roulette",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Roulette wheel
          Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _currentAngle,
                child: CustomPaint(
                  size: const Size(220, 220),
                  painter: _RoulettePainter(_rouletteItems),
                ),
              ),
              // Pointer
              Positioned(
                top: 0,
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 36,
                  color: Colors.red[700],
                ),
              ),
              // Center circle
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: Colors.amber, size: 24),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (rouletteResult.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                rouletteResult,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: isSpinning ? null : _spinRoulette,
            icon: const Icon(Icons.play_arrow),
            label: Text(isSpinning ? "Spinning..." : "Putar!"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================
// ROULETTE PAINTER
// ========================
class _RoulettePainter extends CustomPainter {
  final List<String> items;

  _RoulettePainter(this.items);

  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = 2 * pi / items.length;

    for (int i = 0; i < items.length; i++) {
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweepAngle - pi / 2,
        sweepAngle,
        true,
        paint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: items[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final angle = i * sweepAngle - pi / 2 + sweepAngle / 2;
      final textRadius = radius * 0.65;
      final textOffset = Offset(
        center.dx + textRadius * cos(angle) - textPainter.width / 2,
        center.dy + textRadius * sin(angle) - textPainter.height / 2,
      );

      canvas.save();
      canvas.translate(
        textOffset.dx + textPainter.width / 2,
        textOffset.dy + textPainter.height / 2,
      );
      canvas.rotate(angle + pi / 2);
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // Border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
