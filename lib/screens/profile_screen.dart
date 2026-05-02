import 'dart:ui';
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

  // Time Converter
  final TextEditingController _timeController = TextEditingController();
  String _selectedSourceZone = "WIB";
  Map<String, String> _convertedTimes = {};
  final Map<String, int> _zoneOffsets = {
    "WIB": 7,
    "WITA": 8,
    "WIT": 9,
    "London": 0,
  };

  // Saran
  final TextEditingController _saranController = TextEditingController();
  bool _saranSent = false;

  // Kesan
  final TextEditingController _kesanController = TextEditingController();
  bool _kesanSent = false;

  final List<String> _rouletteItems = [
    "MOTOR! 🎉",
    "5K 😂",
    "10K 😂",
    "20K 😂",
    "100K 😊",
    "500K ⭐",
    "Coba lagi 😅",
  ];

  final List<double> _rouletteProbabilities = [
    0.01,
    0.20,
    0.20,
    0.15,
    0.10,
    0.04,
    0.30,
  ];

  int _weightedRandom() {
    final random = Random();
    final roll = random.nextDouble();
    double cumulative = 0.0;
    for (int i = 0; i < _rouletteProbabilities.length; i++) {
      cumulative += _rouletteProbabilities[i];
      if (roll < cumulative) return i;
    }
    return _rouletteProbabilities.length - 1;
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
      setState(() => _currentAngle = _rouletteAnimation.value);
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
    _timeController.dispose();
    _saranController.dispose();
    _kesanController.dispose();
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
    String text = _currencyController.text.trim();
    if (text.isEmpty) {
      final gaji = user?["gaji"];
      if (gaji == null) {
        setState(() => _convertedResult = "Masukkan Angka");
        return;
      }
      text = gaji.toString();
      _currencyController.text = text;
    }
    final input = double.tryParse(text);
    if (input == null) {
      setState(() => _convertedResult = "Masukkan angka yang valid");
      return;
    }
    final rate = _rates[_selectedCurrency] ?? 1;
    final result = input * rate;
    setState(() {
      _convertedResult =
          "Rp $text = ${result.toStringAsFixed(4)} $_selectedCurrency";
    });
  }

  void _convertTime() {
    final text = _timeController.text.trim();
    if (text.isEmpty) {
      setState(() => _convertedTimes = {});
      return;
    }
    final parts = text.split(":");
    if (parts.length != 2) {
      setState(
        () => _convertedTimes = {"error": "Format salah, gunakan HH:mm"},
      );
      return;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      setState(() => _convertedTimes = {"error": "Waktu tidak valid"});
      return;
    }
    final sourceOffset = _zoneOffsets[_selectedSourceZone] ?? 7;
    final utcMinutes = hour * 60 + minute - sourceOffset * 60;
    final result = <String, String>{};
    _zoneOffsets.forEach((zone, offset) {
      final totalMinutes = (utcMinutes + offset * 60) % (24 * 60);
      final adjusted = totalMinutes < 0 ? totalMinutes + 24 * 60 : totalMinutes;
      final h = adjusted ~/ 60;
      final m = adjusted % 60;
      result[zone] =
          "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
    });
    setState(() => _convertedTimes = result);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background sama dengan Dashboard
        Image.asset("assets/logo_sppg.png", fit: BoxFit.cover),

        // Blur + overlay biru muda seperti Dashboard
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(color: const Color.fromARGB(82, 167, 240, 255)),
        ),

        SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    children: [
                      _profileCard(),
                      const SizedBox(height: 10),
                      _glassMenuCard(
                        icon: Icons.notifications_rounded,
                        color: Colors.orange,
                        title: "Notifikasi",
                        subtitle: "Lihat notifikasi masuk",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _currencyCard(),
                      const SizedBox(height: 10),
                      _timeConverterCard(),
                      const SizedBox(height: 10),
                      _rouletteCard(),
                      const SizedBox(height: 10),
                      _saranCard(),
                      const SizedBox(height: 10),
                      _kesanCard(),
                      const SizedBox(height: 10),
                      _glassMenuCard(
                        icon: Icons.logout_rounded,
                        color: Colors.red,
                        title: "Logout",
                        subtitle: "Keluar dari akun",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: const Color(0xFF1A1A2E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: Color(0x40FFFFFF),
                                ),
                              ),
                              title: const Text(
                                "Konfirmasi Logout",
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                "Apakah kamu yakin ingin logout?",
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    "Batal",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    logout();
                                  },
                                  child: const Text(
                                    "Logout",
                                    style: TextStyle(color: Colors.redAccent),
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
      ],
    );
  }

  // ========================
  // PROFILE CARD
  // ========================
  Widget _profileCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xCC2196F3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x4D64B5F6), width: 1.2),
          ),
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x661565C0),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                  image: DecorationImage(
                    image: user != null && user!["foto_profil"] != null
                        ? NetworkImage(user!["foto_profil"])
                        : const AssetImage("assets/profile.png")
                              as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x40FFFFFF)),
                ),
                child: Text(
                  user?["role"] ?? "-",
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x22FFFFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Gaji: Rp ${user?["gaji"] ?? 0}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================
  // GLASS MENU CARD
  // ========================
  Widget _glassMenuCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xCC37474F),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withAlpha(60)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withAlpha(80)),
                  ),
                  child: Icon(icon, color: color, size: 22),
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
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========================
  // GLASS CARD WRAPPER
  // ========================
  Widget _glassCard({required Widget child, required Color bgColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withAlpha(60)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _cardHeader(IconData icon, Color color, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(50),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ========================
  // CURRENCY CARD
  // ========================
  Widget _currencyCard() {
    return _glassCard(
      bgColor: const Color(0xCC1B5E20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            Icons.currency_exchange_rounded,
            Colors.greenAccent,
            "Konversi Mata Uang",
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _currencyController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "Rp ${user?["gaji"] ?? "Jumlah"}",
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: const Color(0x1AFFFFFF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0x33FFFFFF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0x33FFFFFF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white54),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  dropdownColor: const Color(0xFF1A237E),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  iconEnabledColor: Colors.white70,
                  items: _rates.keys
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCurrency = val!),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _convertCurrency,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.withAlpha(200),
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Convert",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          if (_convertedResult.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.greenAccent.withAlpha(80)),
              ),
              child: Text(
                _convertedResult,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ========================
  // TIME CONVERTER CARD
  // ========================
  Widget _timeConverterCard() {
    final zoneColors = {
      "WIB": Colors.white,
      "WITA": Colors.white,
      "WIT": Colors.white,
      "London": Colors.white,
    };

    return _glassCard(
      bgColor: const Color(0xCC0D47A1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            Icons.access_time_rounded,
            Colors.lightBlueAccent,
            "Konversi Zona Waktu",
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _timeController,
                  keyboardType: TextInputType.datetime,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "(cth: 14:30)",
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: const Color(0x1AFFFFFF),
                    prefixIcon: const Icon(
                      Icons.schedule_rounded,
                      color: Colors.lightBlueAccent,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0x33FFFFFF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0x33FFFFFF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white54),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSourceZone,
                  dropdownColor: const Color(0xFF1A237E),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  iconEnabledColor: Colors.white70,
                  items: _zoneOffsets.keys
                      .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedSourceZone = val!),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _convertTime,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent.withAlpha(200),
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Convert",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          if (_convertedTimes.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (_convertedTimes.containsKey("error"))
              Text(
                _convertedTimes["error"]!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.6,
                children: _zoneOffsets.keys.map((zone) {
                  final color = zoneColors[zone] ?? Colors.grey;
                  final isSource = zone == _selectedSourceZone;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(isSource ? 60 : 30),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: color.withAlpha(isSource ? 140 : 80),
                        width: isSource ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              zone,
                              style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _convertedTimes[zone] ?? "-",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (isSource) ...[
                          const Spacer(),
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 12,
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
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
    return _glassCard(
      bgColor: const Color(0xCC4A148C),
      child: Column(
        children: [
          _cardHeader(
            Icons.casino_rounded,
            Colors.purpleAccent,
            "Mini Game Roulette",
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 236,
                height: 236,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.purpleAccent.withAlpha(80),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withAlpha(60),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              Transform.rotate(
                angle: _currentAngle,
                child: CustomPaint(
                  size: const Size(220, 220),
                  painter: _RoulettePainter(_rouletteItems),
                ),
              ),
              Positioned(
                top: 0,
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                  color: Colors.red[400],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x4D000000), blurRadius: 8),
                  ],
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (rouletteResult.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purpleAccent.withAlpha(100)),
              ),
              child: Text(
                rouletteResult,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purpleAccent,
                ),
              ),
            ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: isSpinning ? null : _spinRoulette,
            icon: Icon(
              isSpinning
                  ? Icons.hourglass_top_rounded
                  : Icons.play_arrow_rounded,
            ),
            label: Text(isSpinning ? "Spinning..." : "Putar!"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent.withAlpha(200),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.purple.withAlpha(80),
              disabledForegroundColor: Colors.white54,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // SARAN CARD
  // ========================
  Widget _saranCard() {
    return _glassCard(
      bgColor: const Color(0xCC004D40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.rate_review_rounded, Colors.tealAccent, "Saran"),
          const SizedBox(height: 4),
          const Text(
            "Kalau bisa tambahkan ketentuan / fitur lagi, bagi angkatan selanjutnya seperti cryptocurrency, blockchain, atau backend dengan cloud",
            style: TextStyle(fontSize: 20, color: Colors.white60),textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ========================
  // KESAN CARD
  // ========================
  Widget _kesanCard() {
    return _glassCard(
      bgColor: const Color(0xCC4E342E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            Icons.school_rounded,
            Colors.amberAccent,
            "Kesan Mata Kuliah TPM",
          ),
          const SizedBox(height: 4),
          const Text(
            "Kuliah Teknologi dan Pemrograman Mobile ini sangatlah seru, membuat kami semangat dalam mempelajari bahasa pemrograman baru dan meningkatkan skill pemrograman kami",
            style: TextStyle(fontSize: 20, color: Colors.white60), textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
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

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
