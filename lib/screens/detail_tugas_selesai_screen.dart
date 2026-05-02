import 'package:flutter/material.dart';
import '../services/tugas_service.dart';

class DetailTugasSelesaiScreen extends StatefulWidget {
  final int tugasId;
  final String hari;

  const DetailTugasSelesaiScreen({super.key, required this.tugasId, required this.hari});

  @override
  State<DetailTugasSelesaiScreen> createState() =>
      _DetailTugasSelesaiScreenState();
}

class _DetailTugasSelesaiScreenState
    extends State<DetailTugasSelesaiScreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;

  final primaryColor = const Color.fromARGB(255, 135, 206, 235);

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final res =
        await TugasService.instance.getDetailTugasSelesai(widget.tugasId);

    setState(() {
      data = res;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (data == null) {
      return const Scaffold(
        body: Center(child: Text("Data tidak ditemukan")),
      );
    }

    final sekolahList = data!["sekolah"];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Detail Tugas ${widget.hari}"),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatistik(),
            
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: sekolahList.length,
                itemBuilder: (context, index) {
                  final s = sekolahList[index];
                  return _buildSekolahCard(s);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================
  // STATISTIK
  // ========================
  Widget _buildStatistik() {
    final total = data!["total_mbg"];
    final sampai = data!["mbg_sampai"];
    final perjalanan = data!["mbg_perjalanan"];
    final sppg = data!["mbg_sppg"];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ringkasan Tugas",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem("Total", total),
              _statItem("Sampai", sampai),
              _statItem("Perjalanan", perjalanan),
              _statItem("SPPG", sppg),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String title, int value) {
    return Column(
      children: [
        Text(
          "$value",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(title),
      ],
    );
  }

  // ========================
  // CARD SEKOLAH
  // ========================
  Widget _buildSekolahCard(Map s) {
    final status = s["status"] ?? "-";
    final jam = s["jam_sampai"];

    final isDone = status == "sampai";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.school),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s["nama"] ?? "-",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Status: $status"),

                if (jam != null)
                  Text(
                    "Jam: ${jam.toString().substring(11, 16)}",
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: isDone ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}