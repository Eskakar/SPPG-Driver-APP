import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sppg_driver_app/screens/map_screen.dart';
import 'package:sppg_driver_app/services/location_service.dart';
import 'package:sppg_driver_app/widgets/error_toast.dart';
import '../services/tugas_service.dart';

class CurrentTaskScreen extends StatefulWidget {
  const CurrentTaskScreen({super.key});

  @override
  State<CurrentTaskScreen> createState() => _CurrentTaskScreenState();
}

class _CurrentTaskScreenState extends State<CurrentTaskScreen> {
  Map? tugas;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> openMap(Map sekolah) async {
    try {
      final position = await LocationService.instance.getCurrentLocation();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapScreen(
            driverLat: position.latitude,
            driverLng: position.longitude,
            sekolahLat: sekolah["latitude"],
            sekolahLng: sekolah["longitude"],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, "Gagal mengambil lokasi");
    }
  }

  Future<void> fetchData() async {
    final data = await TugasService.instance.getCurrentTugas();
    setState(() {
      tugas = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (tugas == null) {
      return const Scaffold(
        body: Center(child: Text("Tidak ada tugas berjalan")),
      );
    }

    final sekolahList = tugas!["sekolah"];
    final statistik = tugas!["statistik"];

    return Scaffold(
      body: Stack(
        children: [
          // Background gambar
          Positioned.fill(
            child: Image.asset("assets/logo_sppg.png", fit: BoxFit.cover),
          ),

          // Blur + overlay biru muda
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(color: const Color.fromARGB(82, 167, 240, 255)),
            ),
          ),

          // Konten
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button + judul
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0x33FFFFFF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0x40FFFFFF),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.black,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Tugas Saat Ini",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Progress card
                    _buildProgressCard(statistik),

                    const SizedBox(height: 16),

                    // Label list sekolah
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.school_outlined,
                            color: Colors.black,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Daftar Sekolah",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // List sekolah
                    ...sekolahList.map<Widget>((s) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSekolahCard(s),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // PROGRESS CARD - GLASS BIRU
  // ========================
  Widget _buildProgressCard(Map statistik) {
    final progress = statistik["progress"] as int;
    final total = statistik["total"] as int;
    final mbgSampai = statistik["mbg_sampai"] as int;
    final mbgSppg = statistik["mbg_sppg"] as int;
    final mbgPerjalanan = statistik["mbg_perjalanan"] as int;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xCC6B9FD4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x4D8BB8E8), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.bar_chart_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Progress Pengantaran",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: total > 0 ? mbgSampai / total : 0,
                  minHeight: 10,
                  backgroundColor: Colors.white.withAlpha(80),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF4CAF50),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "$progress%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 12),

              // Statistik row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem("Di SPPG", mbgSppg, Icons.store_outlined),
                  _divider(),
                  _statItem(
                    "Diangkut",
                    mbgPerjalanan,
                    Icons.local_shipping_outlined,
                  ),
                  _divider(),
                  _statItem(
                    "Sampai",
                    mbgSampai,
                    Icons.check_circle_outline_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.white.withAlpha(80));
  }

  Widget _statItem(String title, int value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(
          "$value",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  // ========================
  // SEKOLAH CARD - GLASS HIJAU
  // ========================
  Widget _buildSekolahCard(Map s) {
    final progress = s["progress"] as String;
    final parts = progress.split("/");
    final isDone = parts.length == 2 && parts[0] == parts[1];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xCC6DBF67),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x6693D68D), width: 1),
          ),
          child: Row(
            children: [
              // Icon sekolah
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // Info sekolah
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s["nama"] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white70,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Progress: $progress",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFE65100),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isDone ? "Selesai" : "Proses",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Tombol MAP
              GestureDetector(
                onTap: () => openMap(s),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset("assets/maps.png", fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
