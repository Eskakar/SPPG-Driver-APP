import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/tugas_service.dart';

class DetailTugasSelesaiScreen extends StatefulWidget {
  final int tugasId;
  final String hari;

  const DetailTugasSelesaiScreen({
    super.key,
    required this.tugasId,
    required this.hari,
  });

  @override
  State<DetailTugasSelesaiScreen> createState() =>
      _DetailTugasSelesaiScreenState();
}

class _DetailTugasSelesaiScreenState extends State<DetailTugasSelesaiScreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final res = await TugasService.instance.getDetailTugasSelesai(
      widget.tugasId,
    );
    setState(() {
      data = res;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Stack(
          children: [
            // Background saat loading
            Positioned.fill(
              child: ColoredBox(color: Color.fromARGB(255, 167, 240, 255)),
            ),
            Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    if (data == null) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset("assets/logo_sppg.png", fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  color: const Color.fromARGB(82, 167, 240, 255),
                ),
              ),
            ),
            const Center(
              child: Text(
                "Data tidak ditemukan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    final sekolahList = data!["sekolah"];

    return Scaffold(
      body: Stack(
        children: [
          // ── Background sama dengan CurrentTaskScreen ──
          Positioned.fill(
            child: Image.asset("assets/logo_sppg.png", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(color: const Color.fromARGB(82, 167, 240, 255)),
            ),
          ),

          // ── Konten ──
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
                        Text(
                          "Detail Tugas ${widget.hari}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Statistik card
                    _buildStatistik(),

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
  // STATISTIK — glass biru (sama dengan _buildProgressCard)
  // ========================
  Widget _buildStatistik() {
    final total = data!["total_mbg"] as int? ?? 0;
    final sampai = data!["mbg_sampai"] as int? ?? 0;
    final perjalanan = data!["mbg_perjalanan"] as int? ?? 0;
    final sppg = data!["mbg_sppg"] as int? ?? 0;
    final progress = total > 0 ? (sampai / total) : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xDD1565C0), // biru gelap solid
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF42A5F5), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Ringkasan Tugas",
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
                  value: progress.toDouble(),
                  minHeight: 10,
                  backgroundColor: Colors.white.withAlpha(80),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF4CAF50),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "${(progress * 100).toInt()}% selesai",
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
                  _statItem("Total", total, Icons.inventory_2_outlined),
                  _divider(),
                  _statItem("Di SPPG", sppg, Icons.store_outlined),
                  _divider(),
                  _statItem(
                    "Diangkut",
                    perjalanan,
                    Icons.local_shipping_outlined,
                  ),
                  _divider(),
                  _statItem(
                    "Sampai",
                    sampai,
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
  // SEKOLAH CARD — glass hijau (sama dengan CurrentTaskScreen)
  // ========================
  Widget _buildSekolahCard(Map s) {
    final status = s["status"] ?? "-";
    final jam = s["jam_sampai"];
    final isDone = status == "sampai";

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xDD2E7D32), // hijau gelap solid
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF66BB6A), width: 1.2),
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
                      s["nama"] ?? "-",
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
                          Icons.info_outline_rounded,
                          color: Colors.white70,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Status: $status",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (jam != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Colors.white70,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Jam: ${jam.toString().substring(11, 16)}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                      ? const Color(0xFF1B5E20)
                      : const Color(0xFFE65100),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDone
                        ? const Color(0xFF66BB6A)
                        : const Color(0xFFFF8A65),
                    width: 1,
                  ),
                ),
                child: Text(
                  isDone ? "Sampai ✓" : "Belum",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
